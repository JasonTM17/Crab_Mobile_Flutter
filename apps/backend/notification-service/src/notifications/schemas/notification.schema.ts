import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type NotificationDocument = Notification & Document

export enum NotificationType {
  RIDE_UPDATE = 'ride_update',
  ORDER_UPDATE = 'order_update',
  PAYMENT = 'payment',
  PROMO = 'promo',
  SYSTEM = 'system',
  CHAT = 'chat',
}

@Schema({ timestamps: true, collection: 'notifications' })
export class Notification {
  @Prop({ required: true, index: true })
  user_id!: string

  @Prop({ required: true })
  title!: string

  @Prop({ required: true })
  body!: string

  @Prop({ type: String, enum: NotificationType, required: true })
  type!: NotificationType

  @Prop('mixed')
  data?: Record<string, any>

  @Prop({ type: Boolean, default: false })
  is_read!: boolean

  @Prop({ type: Date, default: Date.now })
  sent_at!: Date
}

export const NotificationSchema = SchemaFactory.createForClass(Notification)
NotificationSchema.index({ user_id: 1, sent_at: -1 })
NotificationSchema.index({ user_id: 1, is_read: 1 })
