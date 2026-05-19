import {
  Injectable,
  BadRequestException,
  ForbiddenException,
  Logger,
} from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { DataSource, Repository } from 'typeorm'
import { WalletEntity } from './entities/wallet.entity'
import {
  TransactionEntity,
  TransactionStatus,
  TransactionType,
} from '../transactions/entities/transaction.entity'
import { TopUpDto, WithdrawDto, TransferDto } from './dto/wallet.dto'

@Injectable()
export class WalletService {
  private readonly logger = new Logger(WalletService.name)

  constructor(
    @InjectRepository(WalletEntity)
    private readonly walletRepo: Repository<WalletEntity>,
    @InjectRepository(TransactionEntity)
    private readonly txRepo: Repository<TransactionEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async getOrCreate(userId: string): Promise<WalletEntity> {
    let wallet = await this.walletRepo.findOne({ where: { userId } })
    if (!wallet) {
      wallet = this.walletRepo.create({ userId, balance: 0, pendingBalance: 0 })
      await this.walletRepo.save(wallet)
    }
    return wallet
  }

  async getBalance(userId: string) {
    const wallet = await this.getOrCreate(userId)
    return {
      userId,
      balance: Number(wallet.balance),
      pendingBalance: Number(wallet.pendingBalance),
      currency: wallet.currency,
      frozen: wallet.frozen,
    }
  }

  async topUp(userId: string, dto: TopUpDto): Promise<TransactionEntity> {
    return this.dataSource.transaction(async (manager) => {
      const wallet = await this.getOrCreateForUpdate(userId, manager)
      if (wallet.frozen) throw new ForbiddenException('Wallet frozen')

      wallet.balance = Number(wallet.balance) + dto.amount
      await manager.save(wallet)

      const tx = manager.create(TransactionEntity, {
        userId,
        type: TransactionType.TOP_UP,
        amount: dto.amount,
        status: TransactionStatus.COMPLETED,
        paymentMethod: dto.paymentMethod,
        reference: dto.reference,
        balanceAfter: wallet.balance,
        description: `Top up via ${dto.paymentMethod}`,
      })
      await manager.save(tx)

      this.logger.log(`Top-up ${dto.amount} for user ${userId}`)
      return tx
    })
  }

  async deduct(
    userId: string,
    amount: number,
    description: string,
    referenceId?: string,
  ): Promise<TransactionEntity> {
    return this.dataSource.transaction(async (manager) => {
      const wallet = await this.getOrCreateForUpdate(userId, manager)
      if (wallet.frozen) throw new ForbiddenException('Wallet frozen')
      if (Number(wallet.balance) < amount) {
        throw new BadRequestException('Insufficient balance')
      }

      wallet.balance = Number(wallet.balance) - amount
      await manager.save(wallet)

      const tx = manager.create(TransactionEntity, {
        userId,
        type: TransactionType.PAYMENT,
        amount: -amount,
        status: TransactionStatus.COMPLETED,
        balanceAfter: wallet.balance,
        description,
        referenceId,
      })
      await manager.save(tx)

      this.logger.log(`Deduct ${amount} from user ${userId}: ${description}`)
      return tx
    })
  }

  async credit(
    userId: string,
    amount: number,
    description: string,
    type: TransactionType = TransactionType.CREDIT,
    referenceId?: string,
  ): Promise<TransactionEntity> {
    return this.dataSource.transaction(async (manager) => {
      const wallet = await this.getOrCreateForUpdate(userId, manager)
      wallet.balance = Number(wallet.balance) + amount
      await manager.save(wallet)

      const tx = manager.create(TransactionEntity, {
        userId,
        type,
        amount,
        status: TransactionStatus.COMPLETED,
        balanceAfter: wallet.balance,
        description,
        referenceId,
      })
      await manager.save(tx)
      return tx
    })
  }

  async transfer(fromUserId: string, dto: TransferDto): Promise<TransactionEntity> {
    if (fromUserId === dto.toUserId) {
      throw new BadRequestException('Cannot transfer to yourself')
    }
    return this.dataSource.transaction(async (manager) => {
      // CRITICAL: lock wallets in deterministic order (smaller userId first) to avoid
      // deadlock when two transfers in opposite directions run concurrently.
      const [firstId, secondId] = [fromUserId, dto.toUserId].sort()
      const firstWallet = await this.getOrCreateForUpdate(firstId, manager)
      const secondWallet = await this.getOrCreateForUpdate(secondId, manager)
      const fromWallet = firstId === fromUserId ? firstWallet : secondWallet
      const toWallet = firstId === fromUserId ? secondWallet : firstWallet

      if (fromWallet.frozen || toWallet.frozen) {
        throw new ForbiddenException('Wallet frozen')
      }
      if (Number(fromWallet.balance) < dto.amount) {
        throw new BadRequestException('Insufficient balance')
      }

      fromWallet.balance = Number(fromWallet.balance) - dto.amount
      toWallet.balance = Number(toWallet.balance) + dto.amount
      await manager.save([fromWallet, toWallet])

      const description = dto.note ?? `Transfer to ${dto.toUserId}`

      const fromTx = manager.create(TransactionEntity, {
        userId: fromUserId,
        type: TransactionType.TRANSFER_OUT,
        amount: -dto.amount,
        status: TransactionStatus.COMPLETED,
        balanceAfter: fromWallet.balance,
        description,
        referenceId: dto.toUserId,
      })
      const toTx = manager.create(TransactionEntity, {
        userId: dto.toUserId,
        type: TransactionType.TRANSFER_IN,
        amount: dto.amount,
        status: TransactionStatus.COMPLETED,
        balanceAfter: toWallet.balance,
        description: `Received from ${fromUserId}`,
        referenceId: fromUserId,
      })
      await manager.save([fromTx, toTx])
      return fromTx
    })
  }

  async withdraw(userId: string, dto: WithdrawDto): Promise<TransactionEntity> {
    return this.dataSource.transaction(async (manager) => {
      const wallet = await this.getOrCreateForUpdate(userId, manager)
      if (wallet.frozen) throw new ForbiddenException('Wallet frozen')
      if (Number(wallet.balance) < dto.amount) {
        throw new BadRequestException('Insufficient balance')
      }
      wallet.balance = Number(wallet.balance) - dto.amount
      wallet.pendingBalance = Number(wallet.pendingBalance) + dto.amount
      await manager.save(wallet)

      const tx = manager.create(TransactionEntity, {
        userId,
        type: TransactionType.WITHDRAW,
        amount: -dto.amount,
        status: TransactionStatus.PENDING,
        balanceAfter: wallet.balance,
        description: `Withdraw to ${dto.bankName} - ${dto.bankAccount}`,
      })
      await manager.save(tx)
      return tx
    })
  }

  async freeze(userId: string) {
    await this.walletRepo.update(userId, { frozen: true })
    return this.getBalance(userId)
  }

  async unfreeze(userId: string) {
    await this.walletRepo.update(userId, { frozen: false })
    return this.getBalance(userId)
  }

  private async getOrCreateForUpdate(
    userId: string,
    manager: any,
  ): Promise<WalletEntity> {
    let wallet = await manager.findOne(WalletEntity, {
      where: { userId },
      lock: { mode: 'pessimistic_write' },
    })
    if (!wallet) {
      wallet = manager.create(WalletEntity, { userId, balance: 0, pendingBalance: 0 })
      await manager.save(wallet)
    }
    return wallet
  }
}
