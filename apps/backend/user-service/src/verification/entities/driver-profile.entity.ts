import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm'

export enum DriverVerificationStatus {
  PENDING = 'PENDING',
  IN_REVIEW = 'IN_REVIEW',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

@Entity('driver_profiles')
export class DriverProfileEntity {
  @PrimaryColumn('uuid')
  userId!: string

  @Column({ unique: true })
  licenseNumber!: string

  @Column()
  licenseExpiry!: Date

  @Column()
  vehicleType!: string

  @Column()
  vehiclePlate!: string

  @Column()
  vehicleBrand!: string

  @Column()
  vehicleModel!: string

  @Column({ nullable: true })
  vehicleColor?: string

  @Column({ nullable: true })
  vehicleYear?: number

  @Column({ nullable: true })
  insuranceNumber?: string

  @Column({ type: 'date', nullable: true })
  insuranceExpiry?: Date

  @Column({ type: 'enum', enum: DriverVerificationStatus, default: DriverVerificationStatus.PENDING })
  verificationStatus!: DriverVerificationStatus

  @Column({ nullable: true, type: 'text' })
  rejectionReason?: string

  @Column({ default: 0, type: 'decimal', precision: 3, scale: 2 })
  rating!: number

  @Column({ default: 0 })
  totalRides!: number

  @Column({ default: false })
  isOnline!: boolean

  @CreateDateColumn()
  createdAt!: Date

  @UpdateDateColumn()
  updatedAt!: Date
}
