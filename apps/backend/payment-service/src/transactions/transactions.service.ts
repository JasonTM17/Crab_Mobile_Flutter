import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { TransactionEntity, TransactionType, TransactionStatus } from './entities/transaction.entity'
import { WalletService } from '../wallet/wallet.service'

@Injectable()
export class TransactionsService {
  constructor(
    @InjectRepository(TransactionEntity)
    private readonly txRepo: Repository<TransactionEntity>,
    private readonly walletService: WalletService,
  ) {}

  async createPayment(userId: string, amount: number, referenceId?: string, description?: string) {
    const wallet = await this.walletService.getOrCreate(userId)
    const balanceBefore = Number(wallet.balance)

    await this.walletService.deduct(userId, amount)

    const tx = this.txRepo.create({
      wallet_id: wallet.id,
      user_id: userId,
      type: TransactionType.PAYMENT,
      amount,
      balance_before: balanceBefore,
      balance_after: balanceBefore - amount,
      status: TransactionStatus.COMPLETED,
      reference_id: referenceId,
      description,
    })
    return this.txRepo.save(tx)
  }

  async createTopUp(userId: string, amount: number, description?: string) {
    const wallet = await this.walletService.getOrCreate(userId)
    const balanceBefore = Number(wallet.balance)

    await this.walletService.topUp(userId, amount)

    const tx = this.txRepo.create({
      wallet_id: wallet.id,
      user_id: userId,
      type: TransactionType.TOP_UP,
      amount,
      balance_before: balanceBefore,
      balance_after: balanceBefore + amount,
      status: TransactionStatus.COMPLETED,
      description,
    })
    return this.txRepo.save(tx)
  }

  async createRefund(userId: string, amount: number, referenceId: string) {
    const wallet = await this.walletService.getOrCreate(userId)
    const balanceBefore = Number(wallet.balance)

    await this.walletService.topUp(userId, amount)

    const tx = this.txRepo.create({
      wallet_id: wallet.id,
      user_id: userId,
      type: TransactionType.REFUND,
      amount,
      balance_before: balanceBefore,
      balance_after: balanceBefore + amount,
      status: TransactionStatus.COMPLETED,
      reference_id: referenceId,
      description: `Refund for ${referenceId}`,
    })
    return this.txRepo.save(tx)
  }

  async getHistory(userId: string, limit = 20, offset = 0) {
    return this.txRepo.find({
      where: { user_id: userId },
      order: { created_at: 'DESC' },
      take: limit,
      skip: offset,
    })
  }

  async getById(id: string) {
    return this.txRepo.findOneBy({ id })
  }
}
