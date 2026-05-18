import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type MessageDocument = Message & Document

@Schema({ timestamps: true, collection: 'messages' })
export class Message {
  @Prop({ required: true, index: true })
  conversation_id!: string

  @Prop({ required: true })
  sender_id!: string

  @Prop({ required: true })
  content!: string

  @Prop({ type: String, enum: ['text', 'image', 'location'], default: 'text' })
  type!: string

  @Prop({ type: [String], default: [] })
  read_by!: string[]

  @Prop({ type: Date, default: Date.now })
  sent_at!: Date
}

export const MessageSchema = SchemaFactory.createForClass(Message)
MessageSchema.index({ conversation_id: 1, sent_at: -1 })
