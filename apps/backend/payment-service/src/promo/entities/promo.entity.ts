import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm'

export enum PromoType {
  PERCENTAGE = 'PERCENTAGE',
  FIXED = 'FIXED',
  FREE_RIDE = 'FREE_RIDE',
}

export enum PromoApplicableTo {
  RIDE = 'RIDE',
  FOOD = 'FOOD',
  ALL = 'ALL',
}

@Entity('promos')
@Index(['code'], { unique: true })
export class PromoEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ unique: true })
  code!: string

  @Column()
  name!: string

  @Column({ nullable: true, type: 'text' })
  description?: string

  @Column({ type: 'enum', enum: PromoType })
  type!: PromoType

  @Column({ type: 'decimal', precision: 14, scale: 2 })
  value!: number

  @Column({ type: 'decimal', precision: 14, scale: 2, default: 0 })
  minOrderValue!: number

  @Column({ type: 'decimal', precision: 14, scale: 2, nullable: true })
  maxDiscount?: number

  @Column({ type: 'enum', enum: PromoApplicableTo, default: PromoApplicableTo.ALL })
  applicableTo!: PromoApplicableTo

  @Column({ default: 1 })
  usageLimitPerUser!: number

  @Column({ nullable: true })
  totalUsageLimit?: number

  @Column({ default: 0 })
  totalUsed!: number

  @Column({ type: 'timestamp' })
  validFrom!: Date

  @Column({ type: 'timestamp' })
  validUntil!: Date

  @Column({ default: true })
  isActive!: boolean

  @Column({ default: false })
  firstRideOnly!: boolean

  @CreateDateColumn()
  createdAt!: Date

  @UpdateDateColumn()
  updatedAt!: Date
}

@Entity('promo_usages')
@Index(['userId', 'promoId'])
export class PromoUsageEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  userId!: string

  @Column()
  promoId!: string

  @ManyToOne(() => PromoEntity)
  @JoinColumn({ name: 'promoId' })
  promo!: PromoEntity

  @Column({ nullable: true })
  referenceId?: string

  @Column({ type: 'decimal', precision: 14, scale: 2 })
  discountAmount!: number

  @CreateDateColumn()
  usedAt!: Date
}
