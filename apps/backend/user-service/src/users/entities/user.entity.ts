import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm'
import { UserRole, UserStatus } from '@crab/common-types'

@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Index({ unique: true })
  @Column({ unique: true })
  email!: string

  @Index({ unique: true })
  @Column({ unique: true })
  phone!: string

  @Column({ name: 'first_name' })
  firstName!: string

  @Column({ name: 'last_name' })
  lastName!: string

  @Column({ type: 'enum', enum: UserRole, default: UserRole.RIDER })
  role!: UserRole

  @Column({ type: 'enum', enum: UserStatus, default: UserStatus.ACTIVE })
  status!: UserStatus

  @Column({ name: 'avatar_url', nullable: true, type: 'text' })
  avatarUrl?: string

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt!: Date
}
