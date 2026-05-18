import { Entity, PrimaryColumn, Column, UpdateDateColumn } from 'typeorm'
import { RatingTargetType } from './rating.entity'

@Entity('rating_aggregates')
export class RatingAggregateEntity {
  @PrimaryColumn() targetId!: string
  @PrimaryColumn({ type: 'enum', enum: RatingTargetType }) targetType!: RatingTargetType
  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 }) avgScore!: number
  @Column({ default: 0 }) totalRatings!: number
  @Column({ default: 0 }) count1!: number
  @Column({ default: 0 }) count2!: number
  @Column({ default: 0 }) count3!: number
  @Column({ default: 0 }) count4!: number
  @Column({ default: 0 }) count5!: number
  @UpdateDateColumn() updatedAt!: Date
}
