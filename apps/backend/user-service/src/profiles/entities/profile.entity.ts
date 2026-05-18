import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm'
import { UserRole, UserStatus } from '@crab/common-types'

@Entity('profiles')
export class ProfileEntity {
  @PrimaryColumn('uuid')
  userId!: string

  @Column()
  email!: string

  @Column()
  phone!: string

  @Column()
  firstName!: string

  @Column()
  lastName!: string

  @Column({ type: 'enum', enum: UserRole, default: UserRole.RIDER })
  role!: UserRole

  @Column({ type: 'enum', enum: UserStatus, default: UserStatus.ACTIVE })
  status!: UserStatus

  @Column({ nullable: true })
  avatarUrl?: string

  @Column({ type: 'date', nullable: true })
  dateOfBirth?: Date

  @Column({ nullable: true })
  gender?: string

  @Column({ nullable: true, length: 500 })
  bio?: string

  @Column({ default: 'vi' })
  preferredLanguage!: string

  @Column({ default: 'VND' })
  preferredCurrency!: string

  @Column({ nullable: true })
  emergencyContactName?: string

  @Column({ nullable: true })
  emergencyContactPhone?: string

  @CreateDateColumn()
  createdAt!: Date

  @UpdateDateColumn()
  updatedAt!: Date
}
