import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm'

@Entity('restaurants')
@Index(['merchantId'])
@Index(['city'])
export class RestaurantEntity {
  @PrimaryGeneratedColumn('uuid') id!: string
  @Column() merchantId!: string
  @Column() name!: string
  @Column({ nullable: true, type: 'text' }) description?: string
  @Column({ nullable: true }) coverImageUrl?: string
  @Column({ nullable: true }) logoUrl?: string
  @Column() phone!: string
  @Column() address!: string
  @Column({ nullable: true }) city?: string
  @Column('decimal', { precision: 10, scale: 7 }) latitude!: number
  @Column('decimal', { precision: 10, scale: 7 }) longitude!: number
  @Column({ default: 'OTHER' }) cuisineType!: string
  @Column({ default: 0, type: 'decimal', precision: 3, scale: 2 }) rating!: number
  @Column({ default: 0 }) totalReviews!: number
  @Column({ default: 0 }) totalOrders!: number
  @Column({ default: 30 }) avgPrepTimeMin!: number
  @Column('decimal', { precision: 10, scale: 2, default: 15000 }) deliveryFee!: number
  @Column('decimal', { precision: 10, scale: 2, default: 0 }) minOrderValue!: number
  @Column({ default: '08:00' }) openTime!: string
  @Column({ default: '22:00' }) closeTime!: string
  @Column({ default: true }) isOpen!: boolean
  @Column({ default: false }) isFeatured!: boolean
  @Column({ default: false }) acceptsCod!: boolean
  @CreateDateColumn() createdAt!: Date
  @UpdateDateColumn() updatedAt!: Date
}
