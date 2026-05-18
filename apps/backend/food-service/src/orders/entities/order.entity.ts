import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm'
import { OrderStatus } from '@crab/common-types'

@Entity('orders')
export class OrderEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column('uuid')
  user_id!: string

  @Column()
  restaurant_id!: string

  @Column('uuid', { nullable: true })
  driver_id?: string

  @Column('jsonb')
  items!: {
    menu_item_id: string
    name: string
    quantity: number
    price: number
    variant?: string
    addons?: string[]
  }[]

  @Column('decimal', { precision: 12, scale: 2 })
  subtotal!: number

  @Column('decimal', { precision: 12, scale: 2, default: 15000 })
  delivery_fee!: number

  @Column('decimal', { precision: 12, scale: 2 })
  total!: number

  @Column({ type: 'enum', enum: OrderStatus, default: OrderStatus.PLACED })
  status!: OrderStatus

  @Column()
  delivery_address!: string

  @Column('decimal', { precision: 10, scale: 7 })
  delivery_lat!: number

  @Column('decimal', { precision: 10, scale: 7 })
  delivery_lng!: number

  @Column({ nullable: true })
  notes?: string

  @CreateDateColumn()
  created_at!: Date

  @UpdateDateColumn()
  updated_at!: Date
}
