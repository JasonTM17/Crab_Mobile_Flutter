import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm'

@Entity('promo_codes')
export class PromoCodeEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column({ unique: true })
  code!: string

  @Column()
  description!: string

  @Column('decimal', { precision: 5, scale: 2 })
  discount_percent!: number

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  max_discount?: number

  @Column('decimal', { precision: 12, scale: 2, default: 0 })
  min_order_amount!: number

  @Column({ type: 'integer', default: 100 })
  max_uses!: number

  @Column({ type: 'integer', default: 0 })
  current_uses!: number

  @Column({ type: 'timestamptz' })
  valid_from!: Date

  @Column({ type: 'timestamptz' })
  valid_until!: Date

  @Column({ type: 'boolean', default: true })
  is_active!: boolean

  @CreateDateColumn()
  created_at!: Date

  @UpdateDateColumn()
  updated_at!: Date
}
