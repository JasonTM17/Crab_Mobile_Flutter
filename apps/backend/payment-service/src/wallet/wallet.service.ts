import { Injectable, BadRequestException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, DataSource } from 'typeorm'
import { WalletEntity } from './entities/wallet.entity'

@Injectable()
export class WalletService {
  constructor(
    @InjectRepository(WalletEntity)
    private readonly walletRepo: Repository<WalletEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async getOrCreate(userId: string): Promise<WalletEntity> {
    let wallet = await this.walletRepo.findOneBy({ user_id: userId })
    if (!wallet) {
      wallet = this.walletRepo.create({ user_id: userId, balance: 0 })
      wallet = await this.walletRepo.save(wallet)
    }
    return wallet
  }

  async getBalance(userId: string): Promise<number> {
    const wallet = await this.getOrCreate(userId)
    return Number(wallet.balance)
  }

  async topUp(userId: string, amount: number): Promise<WalletEntity> {
    if (amount <= 0) throw new BadRequestException('Amount must be positive')

    return this.dataSource.transaction(async (manager) => {
      const wallet = await manager.findOne(WalletEntity, {
        where: { user_id: userId },
        lock: { mode: 'pessimistic_write' },
      })
      if (!wallet) throw new BadRequestException('Wallet not found')

      wallet.balance = Number(wallet.balance) + amount
      return manager.save(wallet)
    })
  }

  async deduct(userId: string, amount: number): Promise<WalletEntity> {
    if (amount <= 0) throw new BadRequestException('Amount must be positive')

    return this.dataSource.transaction(async (manager) => {
      const wallet = await manager.findOne(WalletEntity, {
        where: { user_id: userId },
        lock: { mode: 'pessimistic_write' },
      })
      if (!wallet) throw new BadRequestException('Wallet not found')
      if (Number(wallet.balance) < amount) {
        throw new BadRequestException('Insufficient balance')
      }

      wallet.balance = Number(wallet.balance) - amount
      return manager.save(wallet)
    })
  }

  async withdraw(userId: string, amount: number): Promise<WalletEntity> {
    return this.deduct(userId, amount)
  }
}
