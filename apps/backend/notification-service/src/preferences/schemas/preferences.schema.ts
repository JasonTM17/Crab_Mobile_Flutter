import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type PreferencesDocument = NotificationPreferences & Document

@Schema({ timestamps: true })
export class NotificationPreferences {
  @Prop({ required: true, unique: true, index: true })
  userId!: string

  @Prop({ default: true })
  pushEnabled!: boolean

  @Prop({ default: true })
  emailEnabled!: boolean

  @Prop({ default: true })
  smsEnabled!: boolean

  @Prop({ default: true })
  rideEnabled!: boolean

  @Prop({ default: true })
  orderEnabled!: boolean

  @Prop({ default: true })
  chatEnabled!: boolean

  @Prop({ default: true })
  promoEnabled!: boolean

  @Prop({ default: true })
  systemEnabled!: boolean

  @Prop({ type: [String], default: [] })
  fcmTokens!: string[]
}

export const PreferencesSchema = SchemaFactory.createForClass(NotificationPreferences)
