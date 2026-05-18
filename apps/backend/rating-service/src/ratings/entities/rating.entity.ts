import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm'

export enum RatingTargetType {
  DRIVER = 'DRIVER',
  RIDER = 'RIDER',
  RESTAURANT = 'RESTAURANT',
  DELIVERY = 'DELIVERY',
}

export enum RatingContext {
  RIDE = 'RIDE',
  ORDER = 'ORDER',
}

@Entity('ratings')
@Index(['targetId', 'targetType'])
@Index(['raterId'])
@Index(['referenceId'], { unique: true })
export class RatingEntity {
  @PrimaryGeneratedColumn('uuid') id!: string
  @Column() raterId!: string
  @Column() targetId!: string
  @Column({ type: 'enum', enum: RatingTargetType }) targetType!: RatingTargetType
  @Column({ type: 'enum', enum: RatingContext }) context!: RatingContext
  @Column() referenceId!: string
  @Column({ type: 'smallint' }) score!: number
  @Column({ nullable: true, type: 'text' }) review?: string
  @Column({ type: 'jsonb', nullable: true }) tags?: string[]
  @Column({ type: 'jsonb', nullable: true }) photos?: string[]
  @Column({ default: false }) flagged!: boolean
  @Column({ nullable: true, type: 'text' }) flagReason?: string
  @Column({ default: false }) hidden!: boolean
  @CreateDateColumn() createdAt!: Date
}
