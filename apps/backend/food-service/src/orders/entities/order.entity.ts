import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Index,
} from 'typeorm'
import { OrderStatus } from '@crab/common-types'
import { OrderItemEntity } from './order-item.entity'

@Entity('orders')
@Index(['customerId'])
@Index(['restaurantId'])
@Index(['status'])
@Index(['createdAt'])
export class OrderEntity {
  @PrimaryGeneratedColumn('uuid') id!: string
  @Column() customerId!: string
  @Column() restaurantId!: string
  @Column({ nullable: true }) driverId?: string
  @Column({ type: 'enum', enum: OrderStatus, default: OrderStatus.PLACED })
  status!: OrderStatus
  @Column('decimal', { precision: 10, scale: 7 }) deliveryLat!: number
  @Column('decimal', { precision: 10, scale: 7 }) deliveryLng!: number
  @Column() deliveryAddress!: string
  @Column({ nullable: true }) deliveryNotes?: string
  @Column('decimal', { precision: 12, scale: 2 }) subtotal!: number
  @Column('decimal', { precision: 12, scale: 2, default: 0 }) deliveryFee!: number
  @Column('decimal', { precision: 12, scale: 2, default: 0 }) discount!: number
  @Column('decimal', { precision: 12, scale: 2 }) total!: number
  @Column({ default: 'WALLET' }) paymentMethod!: string
  @Column({ default: false }) paid!: boolean
  @Column({ nullable: true }) promoCode?: string
  @Column({ type: 'timestamp', nullable: true }) confirmedAt?: Date
  @Column({ type: 'timestamp', nullable: true }) preparedAt?: Date
  @Column({ type: 'timestamp', nullable: true }) pickedUpAt?: Date
  @Column({ type: 'timestamp', nullable: true }) deliveredAt?: Date
  @Column({ type: 'timestamp', nullable: true }) cancelledAt?: Date
  @Column({ nullable: true, type: 'text' }) cancellationReason?: string

  @OneToMany(() => OrderItemEntity, (i) => i.order, { cascade: true })
  items!: OrderItemEntity[]

  @CreateDateColumn() createdAt!: Date
  @UpdateDateColumn() updatedAt!: Date
}
