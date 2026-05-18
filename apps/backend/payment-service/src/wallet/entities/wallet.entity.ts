import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  VersionColumn,
} from 'typeorm'

@Entity('wallets')
export class WalletEntity {
  @PrimaryColumn('uuid')
  userId!: string

  @Column({ type: 'decimal', precision: 14, scale: 2, default: 0 })
  balance!: number

  @Column({ default: 'VND' })
  currency!: string

  @Column({ type: 'decimal', precision: 14, scale: 2, default: 0 })
  pendingBalance!: number

  @Column({ default: false })
  frozen!: boolean

  @VersionColumn()
  version!: number

  @CreateDateColumn()
  createdAt!: Date

  @UpdateDateColumn()
  updatedAt!: Date
}
