import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type MessageDocument = ChatMessage & Document

export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  LOCATION = 'location',
  QUICK_REPLY = 'quick_reply',
  SYSTEM = 'system',
}

@Schema({ timestamps: true, collection: 'chat_messages' })
export class ChatMessage {
  @Prop({ required: true, index: true })
  roomId!: string

  @Prop({ required: true, index: true })
  senderId!: string

  @Prop({ required: true })
  content!: string

  @Prop({ enum: MessageType, default: MessageType.TEXT })
  type!: MessageType

  @Prop({ type: Object })
  metadata?: {
    imageUrl?: string
    latitude?: number
    longitude?: number
    address?: string
    options?: string[]
  }

  @Prop({ type: [String], default: [] })
  readBy!: string[]

  @Prop({ default: false })
  edited!: boolean

  @Prop({ default: false })
  deleted!: boolean
}

export const ChatMessageSchema = SchemaFactory.createForClass(ChatMessage)
ChatMessageSchema.index({ roomId: 1, createdAt: -1 })
