import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm'
import { RideStatus } from '@crab/common-types'

@Entity('rides')
export class RideEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string

  @Column('uuid')
  rider_id!: string

  @Column('uuid', { nullable: true })
  driver_id?: string

  @Column('decimal', { precision: 10, scale: 7 })
  pickup_lat!: number

  @Column('decimal', { precision: 10, scale: 7 })
  pickup_lng!: number

  @Column()
  pickup_address!: string

  @Column('decimal', { precision: 10, scale: 7 })
  dropoff_lat!: number

  @Column('decimal', { precision: 10, scale: 7 })
  dropoff_lng!: number

  @Column()
  dropoff_address!: string

  @Column({ type: 'enum', enum: RideStatus, default: RideStatus.REQUESTED })
  status!: RideStatus

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  fare?: number

  @Column('decimal', { precision: 8, scale: 3, nullable: true })
  distance_km?: number

  @Column('integer', { nullable: true })
  duration_min?: number

  @Column('decimal', { precision: 4, scale: 2, default: 1.0 })
  surge_multiplier!: number

  @Column({ default: 'BIKE' })
  vehicle_type!: string

  @Column({ type: 'timestamp', nullable: true })
  scheduled_at?: Date

  @Column({ default: false })
  is_scheduled!: boolean

  @Column({ default: false })
  sos_triggered!: boolean

  @Column({ type: 'timestamp', nullable: true })
  sos_at?: Date

  @Column({ nullable: true, type: 'text' })
  cancellation_reason?: string

  @Column({ nullable: true })
  payment_method?: string

  @Column({ default: false })
  paid!: boolean

  @Column({ type: 'timestamp', nullable: true })
  pickup_time?: Date

  @Column({ type: 'timestamp', nullable: true })
  start_time?: Date

  @CreateDateColumn()
  created_at!: Date

  @UpdateDateColumn()
  updated_at!: Date

  @Column({ type: 'timestamptz', nullable: true })
  completed_at?: Date
}
