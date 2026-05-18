import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  JoinColumn,
} from 'typeorm'
import { UserEntity } from './user.entity'

@Entity('refresh_tokens')
export class RefreshTokenEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  token!: string

  @Column()
  userId!: string

  @ManyToOne(() => UserEntity, (user: UserEntity) => user.refreshTokens, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user!: UserEntity

  @Column({ default: false })
  revoked!: boolean

  @Column()
  expiresAt!: Date

  @CreateDateColumn()
  createdAt!: Date
}
