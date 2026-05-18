import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm'

@Entity('addresses')
@Index(['userId'])
export class AddressEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column()
  userId!: string

  @Column()
  label!: string

  @Column()
  address!: string

  @Column('decimal', { precision: 10, scale: 7 })
  latitude!: number

  @Column('decimal', { precision: 10, scale: 7 })
  longitude!: number

  @Column({ default: false })
  isDefault!: boolean

  @Column({ nullable: true })
  notes?: string

  @CreateDateColumn()
  createdAt!: Date

  @UpdateDateColumn()
  updatedAt!: Date
}
