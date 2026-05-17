import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm'

export enum TransactionType {
  TOP_UP = 'top_up',
  PAYMENT = 'payment',
  REFUND = 'refund',
  WITHDRAW = 'withdraw',
  PAYOUT = 'payout',
}

export enum TransactionStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

@Entity('transactions')
export class TransactionEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column('uuid')
  wallet_id!: string

  @Column('uuid')
  user_id!: string

  @Column({ type: 'enum', enum: TransactionType })
  type!: TransactionType

  @Column('decimal', { precision: 15, scale: 2 })
  amount!: number

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  balance_before!: number

  @Column('decimal', { precision: 15, scale: 2, default: 0 })
  balance_after!: number

  @Column({ type: 'enum', enum: TransactionStatus, default: TransactionStatus.PENDING })
  status!: TransactionStatus

  @Column({ nullable: true })
  reference_id?: string

  @Column({ nullable: true })
  description?: string

  @Column('jsonb', { nullable: true })
  metadata?: Record<string, any>

  @CreateDateColumn()
  created_at!: Date
}
