import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm'

@Entity('menu_items')
export class MenuItemEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column('uuid')
  restaurant_id!: string

  @Column()
  name!: string

  @Column({ nullable: true })
  description?: string

  @Column('decimal', { precision: 12, scale: 2 })
  price!: number

  @Column({ nullable: true })
  image_url?: string

  @Column()
  category!: string

  @Column({ type: 'boolean', default: true })
  is_available!: boolean

  @Column('jsonb', { default: [] })
  variants!: { name: string; price: number }[]

  @Column('jsonb', { default: [] })
  addons!: { name: string; price: number }[]

  @CreateDateColumn()
  created_at!: Date

  @UpdateDateColumn()
  updated_at!: Date
}
