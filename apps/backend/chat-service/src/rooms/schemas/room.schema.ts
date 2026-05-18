import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type RoomDocument = ChatRoom & Document

export enum RoomType {
  RIDE = 'RIDE',
  ORDER = 'ORDER',
  SUPPORT = 'SUPPORT',
}

export enum RoomStatus {
  ACTIVE = 'ACTIVE',
  ARCHIVED = 'ARCHIVED',
}

@Schema({ timestamps: true, collection: 'chat_rooms' })
export class ChatRoom {
  @Prop({ required: true, enum: RoomType })
  type!: RoomType

  @Prop({ enum: RoomStatus, default: RoomStatus.ACTIVE })
  status!: RoomStatus

  @Prop({ type: [String], required: true, index: true })
  participants!: string[]

  @Prop({ type: String, index: true })
  referenceId?: string

  @Prop()
  lastMessageAt?: Date

  @Prop()
  lastMessagePreview?: string

  @Prop({ type: Object, default: {} })
  unreadCount!: Record<string, number>

  @Prop({ type: Object, default: {} })
  lastReadMessageId!: Record<string, string>
}

export const ChatRoomSchema = SchemaFactory.createForClass(ChatRoom)
ChatRoomSchema.index({ participants: 1, status: 1 })
ChatRoomSchema.index({ referenceId: 1 })
