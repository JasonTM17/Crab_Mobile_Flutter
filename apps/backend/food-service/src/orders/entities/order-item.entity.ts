import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm'
import { OrderEntity } from './order.entity'

@Entity('order_items')
export class OrderItemEntity {
  @PrimaryGeneratedColumn('uuid') id!: string
  @Column() orderId!: string
  @ManyToOne(() => OrderEntity, (o) => o.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'orderId' })
  order!: OrderEntity
  @Column() menuItemId!: string
  @Column() name!: string
  @Column('decimal', { precision: 10, scale: 2 }) price!: number
  @Column({ default: 1 }) quantity!: number
  @Column({ nullable: true, type: 'text' }) notes?: string
  @Column({ type: 'jsonb', nullable: true }) options?: Record<string, any>
}
