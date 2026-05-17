import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose'
import { Document } from 'mongoose'

export type ConversationDocument = Conversation & Document

@Schema({ timestamps: true, collection: 'conversations' })
export class Conversation {
  @Prop({ type: [String], required: true })
  participants!: string[]

  @Prop({ type: String, enum: ['ride', 'food', 'support'], default: 'ride' })
  context_type!: string

  @Prop()
  context_id?: string

  @Prop()
  last_message?: string

  @Prop({ type: Date })
  last_message_at?: Date
}

export const ConversationSchema = SchemaFactory.createForClass(Conversation)
ConversationSchema.index({ participants: 1 })
ConversationSchema.index({ context_type: 1, context_id: 1 })
