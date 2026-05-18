import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, Index } from 'typeorm'

@Entity('menu_categories')
@Index(['restaurantId'])
export class MenuCategoryEntity {
  @PrimaryGeneratedColumn('uuid') id!: string
  @Column() restaurantId!: string
  @Column() name!: string
  @Column({ nullable: true }) description?: string
  @Column({ default: 0 }) sortOrder!: number
  @Column({ default: true }) isActive!: boolean
  @CreateDateColumn() createdAt!: Date
}
