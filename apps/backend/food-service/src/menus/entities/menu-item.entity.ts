import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm'

@Entity('menu_items')
@Index(['restaurantId'])
@Index(['categoryId'])
export class MenuItemEntity {
  @PrimaryGeneratedColumn('uuid') id!: string
  @Column() restaurantId!: string
  @Column() categoryId!: string
  @Column() name!: string
  @Column({ nullable: true, type: 'text' }) description?: string
  @Column({ nullable: true }) imageUrl?: string
  @Column('decimal', { precision: 10, scale: 2 }) price!: number
  @Column('decimal', { precision: 10, scale: 2, nullable: true }) discountPrice?: number
  @Column({ default: true }) isAvailable!: boolean
  @Column({ default: false }) isFeatured!: boolean
  @Column({ default: 0 }) totalSold!: number
  @Column({ default: 15 }) prepTimeMin!: number
  @Column({ type: 'jsonb', nullable: true }) options?: Record<string, any>
  @CreateDateColumn() createdAt!: Date
  @UpdateDateColumn() updatedAt!: Date
}
