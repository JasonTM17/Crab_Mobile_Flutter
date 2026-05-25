import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, Between, FindOptionsWhere } from 'typeorm'
import {
  TransactionEntity,
  TransactionStatus,
  TransactionType,
} from './entities/transaction.entity'

export interface ListOptions {
  page?: number
  limit?: number
  type?: TransactionType
  status?: TransactionStatus
  fromDate?: Date
  toDate?: Date
}

@Injectable()
export class TransactionsService {
  constructor(
    @InjectRepository(TransactionEntity)
    private readonly repo: Repository<TransactionEntity>,
  ) {}

  async listByUser(userId: string, opts: ListOptions = {}) {
    const page = opts.page ?? 1
    const limit = opts.limit ?? 20
    const where: FindOptionsWhere<TransactionEntity> = { userId }
    if (opts.type) where.type = opts.type
    if (opts.status) where.status = opts.status
    if (opts.fromDate && opts.toDate) {
      where.createdAt = Between(opts.fromDate, opts.toDate)
    }

    const [data, total] = await this.repo.findAndCount({
      where,
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    })

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async listAll(opts: ListOptions = {}) {
    const page = opts.page ?? 1
    const limit = opts.limit ?? 20
    const where: FindOptionsWhere<TransactionEntity> = {}
    if (opts.type) where.type = opts.type
    if (opts.status) where.status = opts.status
    if (opts.fromDate && opts.toDate) {
      where.createdAt = Between(opts.fromDate, opts.toDate)
    }

    const [data, total] = await this.repo.findAndCount({
      where,
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    })

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async findById(id: string): Promise<TransactionEntity | null> {
    return this.repo.findOne({ where: { id } })
  }

  async listByReference(referenceId: string): Promise<TransactionEntity[]> {
    return this.repo.find({
      where: { referenceId },
      order: { createdAt: 'ASC' },
    })
  }

  async getSummary(userId: string, fromDate?: Date, toDate?: Date) {
    const where: FindOptionsWhere<TransactionEntity> = { userId }
    if (fromDate && toDate) where.createdAt = Between(fromDate, toDate)
    const txs = await this.repo.find({ where })
    const summary = {
      totalIn: 0,
      totalOut: 0,
      count: txs.length,
      byType: {} as Record<string, { count: number; amount: number }>,
    }
    for (const tx of txs) {
      const amt = Number(tx.amount)
      if (amt > 0) summary.totalIn += amt
      else summary.totalOut += Math.abs(amt)
      const t = tx.type
      if (!summary.byType[t]) summary.byType[t] = { count: 0, amount: 0 }
      summary.byType[t].count++
      summary.byType[t].amount += amt
    }
    return summary
  }
}
