import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

@Schema({ timestamps: true })
export class Review extends Document {
  @Prop({ required: true })
  userId: string

  @Prop({ required: true })
  targetType: string

  @Prop({ required: true })
  targetId: string

  @Prop({ required: true, min: 1, max: 5 })
  score: number

  @Prop()
  comment: string

  @Prop({ type: [String], default: [] })
  tags: string[]

  @Prop({ type: [String], default: [] })
  imageUrls: string[]

  @Prop()
  rideId: string

  @Prop()
  orderId: string

  @Prop({ default: false })
  isHidden: boolean

  @Prop()
  replyContent: string

  @Prop()
  replyAt: Date
}

export const ReviewSchema = SchemaFactory.createForClass(Review)
ReviewSchema.index({ targetType: 1, targetId: 1 })
ReviewSchema.index({ userId: 1 })
