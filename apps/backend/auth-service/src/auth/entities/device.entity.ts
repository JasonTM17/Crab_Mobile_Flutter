import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm'
import { UserEntity } from './user.entity'

@Entity('devices')
@Index(['userId', 'deviceId'], { unique: true })
export class DeviceEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  userId!: string

  @ManyToOne(() => UserEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user!: UserEntity

  @Column()
  deviceId!: string

  @Column({ nullable: true })
  deviceName?: string

  @Column({ nullable: true })
  platform?: string // 'ios' | 'android' | 'web'

  @Column({ nullable: true })
  fcmToken?: string

  @Column({ nullable: true })
  lastIp?: string

  @Column({ type: 'timestamp', nullable: true })
  lastActiveAt?: Date

  @Column({ default: true })
  isActive!: boolean

  @CreateDateColumn()
  createdAt!: Date

  @UpdateDateColumn()
  updatedAt!: Date
}
