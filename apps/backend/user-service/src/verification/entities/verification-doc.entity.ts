import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm'

export enum DocType {
  ID_CARD_FRONT = 'ID_CARD_FRONT',
  ID_CARD_BACK = 'ID_CARD_BACK',
  DRIVING_LICENSE = 'DRIVING_LICENSE',
  VEHICLE_REGISTRATION = 'VEHICLE_REGISTRATION',
  INSURANCE = 'INSURANCE',
  BUSINESS_LICENSE = 'BUSINESS_LICENSE',
  BUSINESS_TAX = 'BUSINESS_TAX',
  PROFILE_PHOTO = 'PROFILE_PHOTO',
}

@Entity('verification_docs')
@Index(['userId', 'docType'])
export class VerificationDocEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  userId!: string

  @Column({ type: 'enum', enum: DocType })
  docType!: DocType

  @Column()
  fileUrl!: string

  @Column({ default: false })
  verified!: boolean

  @Column({ nullable: true })
  verifiedBy?: string

  @Column({ type: 'timestamp', nullable: true })
  verifiedAt?: Date

  @CreateDateColumn()
  uploadedAt!: Date
}
