import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm'

@Entity('ratings')
@Index(['targetType', 'targetId'])
@Index(['userId', 'targetType', 'targetId'], { unique: true })
export class Rating {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column()
  userId: string

  @Column()
  targetType: string // 'driver', 'restaurant', 'rider'

  @Column()
  targetId: string

  @Column({ type: 'decimal', precision: 2, scale: 1 })
  score: number // 1.0 - 5.0

  @Column({ nullable: true })
  rideId: string

  @Column({ nullable: true })
  orderId: string

  @CreateDateColumn()
  createdAt: Date

  @UpdateDateColumn()
  updatedAt: Date
}
