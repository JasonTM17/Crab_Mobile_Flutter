import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type NotificationDocument = Notification & Document

export enum NotificationType {
  RIDE = 'ride',
  ORDER = 'order',
  CHAT = 'chat',
  SYSTEM = 'system',
  PROMO = 'promo',
  PAYMENT = 'payment',
}

export enum NotificationChannel {
  PUSH = 'push',
  IN_APP = 'in_app',
  EMAIL = 'email',
  SMS = 'sms',
}

@Schema({ timestamps: true })
export class Notification {
  @Prop({ required: true, index: true })
  userId!: string

  @Prop({ required: true })
  title!: string

  @Prop({ required: true })
  body!: string

  @Prop({ enum: NotificationType, required: true })
  type!: NotificationType

  @Prop({ type: [String], default: ['in_app', 'push'] })
  channels!: NotificationChannel[]

  @Prop({ type: Object })
  data?: Record<string, any>

  @Prop({ default: false })
  read!: boolean

  @Prop()
  readAt?: Date

  @Prop({ default: false })
  delivered!: boolean

  @Prop()
  deliveredAt?: Date

  @Prop()
  imageUrl?: string

  @Prop()
  deepLink?: string
}

export const NotificationSchema = SchemaFactory.createForClass(Notification)
NotificationSchema.index({ userId: 1, createdAt: -1 })
NotificationSchema.index({ userId: 1, read: 1 })
