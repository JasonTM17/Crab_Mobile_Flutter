import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm'

export enum TransactionType {
  TOP_UP = 'TOP_UP',
  WITHDRAW = 'WITHDRAW',
  PAYMENT = 'PAYMENT',
  REFUND = 'REFUND',
  TRANSFER_IN = 'TRANSFER_IN',
  TRANSFER_OUT = 'TRANSFER_OUT',
  COMMISSION = 'COMMISSION',
  PAYOUT = 'PAYOUT',
  CREDIT = 'CREDIT',
  PROMO = 'PROMO',
}

export enum TransactionStatus {
  PENDING = 'PENDING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
  CANCELLED = 'CANCELLED',
}

@Entity('transactions')
@Index(['userId', 'createdAt'])
@Index(['referenceId'])
export class TransactionEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  userId!: string

  @Column({ type: 'enum', enum: TransactionType })
  type!: TransactionType

  @Column({ type: 'decimal', precision: 14, scale: 2 })
  amount!: number

  @Column({ default: 'VND' })
  currency!: string

  @Column({ type: 'enum', enum: TransactionStatus, default: TransactionStatus.PENDING })
  status!: TransactionStatus

  @Column({ type: 'decimal', precision: 14, scale: 2, nullable: true })
  balanceAfter?: number

  @Column({ nullable: true })
  paymentMethod?: string

  @Column({ nullable: true })
  reference?: string

  @Column({ nullable: true })
  referenceId?: string

  @Column({ nullable: true, type: 'text' })
  description?: string

  @Column({ nullable: true, type: 'jsonb' })
  metadata?: Record<string, any>

  @CreateDateColumn()
  createdAt!: Date
}
