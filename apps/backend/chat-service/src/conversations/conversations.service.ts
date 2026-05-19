import { Injectable } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import { Conversation, ConversationDocument } from './schemas/conversation.schema'

@Injectable()
export class ConversationsService {
  constructor(
    @InjectModel(Conversation.name)
    private readonly conversationModel: Model<ConversationDocument>,
  ) {}

  async findOrCreate(participants: string[], contextType: string, contextId?: string) {
    const existing = await this.conversationModel.findOne({
      participants: { $all: participants, $size: participants.length },
      context_type: contextType,
      ...(contextId ? { context_id: contextId } : {}),
    })
    if (existing) return existing

    return this.conversationModel.create({
      participants,
      context_type: contextType,
      context_id: contextId,
    })
  }

  async getByUser(userId: string) {
    return this.conversationModel
      .find({ participants: userId })
      .sort({ last_message_at: -1 })
      .exec()
  }

  async updateLastMessage(conversationId: string, message: string) {
    await this.conversationModel.findByIdAndUpdate(conversationId, {
      last_message: message,
      last_message_at: new Date(),
    })
  }
}
