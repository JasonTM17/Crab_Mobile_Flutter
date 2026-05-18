import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm'
import { UserRole, UserStatus } from '@crab/common-types'
import { RefreshTokenEntity } from './refresh-token.entity'

@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ unique: true })
  email!: string

  @Column({ unique: true })
  phone!: string

  @Column()
  passwordHash!: string

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

  @Column({ default: false })
  phoneVerified!: boolean

  @Column({ default: false })
  emailVerified!: boolean

  @Column({ type: 'timestamp', nullable: true })
  lockedUntil?: Date

  @Column({ default: 0 })
  failedLoginCount!: number

  @Column({ type: 'timestamp', nullable: true })
  lastLoginAt?: Date

  @OneToMany(() => RefreshTokenEntity, (token: RefreshTokenEntity) => token.user, { cascade: true })
  refreshTokens!: RefreshTokenEntity[]

  @CreateDateColumn()
  createdAt!: Date

  @UpdateDateColumn()
  updatedAt!: Date
}
