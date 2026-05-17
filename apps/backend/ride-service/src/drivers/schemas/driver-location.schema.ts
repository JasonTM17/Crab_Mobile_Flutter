import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type DriverLocationDocument = DriverLocation & Document

export enum DriverStatus {
  ONLINE = 'online',
  BUSY = 'busy',
  OFFLINE = 'offline',
}

export enum VehicleType {
  MOTORBIKE = 'motorbike',
  CAR = 'car',
  VAN = 'van',
}

@Schema({ timestamps: true, collection: 'driver_locations' })
export class DriverLocation {
  @Prop({ required: true, index: true })
  driver_id!: string

  @Prop({
    type: {
      type: String,
      enum: ['Point'],
      required: true,
    },
    coordinates: {
      type: [Number],
      required: true,
    },
  })
  location!: {
    type: 'Point'
    coordinates: [number, number] // [lng, lat]
  }

  @Prop({ type: String, enum: DriverStatus, default: DriverStatus.OFFLINE })
  status!: DriverStatus

  @Prop({ type: String, enum: VehicleType, default: VehicleType.MOTORBIKE })
  vehicle_type!: VehicleType

  @Prop({ type: Number, default: 5.0, min: 1.0, max: 5.0 })
  rating!: number

  @Prop({ type: Date, default: Date.now })
  updated_at!: Date
}

export const DriverLocationSchema = SchemaFactory.createForClass(DriverLocation)

// 2dsphere index for geospatial queries
DriverLocationSchema.index({ location: '2dsphere' })
DriverLocationSchema.index({ driver_id: 1 }, { unique: true })
