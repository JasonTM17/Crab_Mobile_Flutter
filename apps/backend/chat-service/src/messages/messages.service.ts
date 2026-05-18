import { Injectable } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import { Message, MessageDocument } from './schemas/message.schema'

@Injectable()
export class MessagesService {
  constructor(
    @InjectModel(Message.name)
    private readonly messageModel: Model<MessageDocument>,
  ) {}

  async create(conversationId: string, senderId: string, content: string, type = 'text') {
    return this.messageModel.create({
      conversation_id: conversationId,
      sender_id: senderId,
      content,
      type,
      read_by: [senderId],
    })
  }

  async getByConversation(conversationId: string, limit = 50, before?: Date) {
    const filter: any = { conversation_id: conversationId }
    if (before) filter.sent_at = { $lt: before }
    return this.messageModel
      .find(filter)
      .sort({ sent_at: -1 })
      .limit(limit)
      .exec()
  }

  async markAsRead(conversationId: string, userId: string) {
    await this.messageModel.updateMany(
      { conversation_id: conversationId, read_by: { $ne: userId } },
      { $addToSet: { read_by: userId } },
    )
  }
}
