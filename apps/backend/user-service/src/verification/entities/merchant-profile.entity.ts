import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm'

export enum MerchantVerificationStatus {
  PENDING = 'PENDING',
  IN_REVIEW = 'IN_REVIEW',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

@Entity('merchant_profiles')
export class MerchantProfileEntity {
  @PrimaryColumn('uuid')
  userId!: string

  @Column()
  businessName!: string

  @Column()
  businessType!: string

  @Column({ unique: true })
  taxId!: string

  @Column({ nullable: true })
  businessLicense?: string

  @Column()
  businessAddress!: string

  @Column('decimal', { precision: 10, scale: 7, nullable: true })
  latitude?: number

  @Column('decimal', { precision: 10, scale: 7, nullable: true })
  longitude?: number

  @Column({ type: 'enum', enum: MerchantVerificationStatus, default: MerchantVerificationStatus.PENDING })
  verificationStatus!: MerchantVerificationStatus

  @Column({ nullable: true, type: 'text' })
  rejectionReason?: string

  @Column({ default: 0, type: 'decimal', precision: 3, scale: 2 })
  rating!: number

  @CreateDateColumn()
  createdAt!: Date

  @UpdateDateColumn()
  updatedAt!: Date
}
