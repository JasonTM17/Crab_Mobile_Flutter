import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import { ChatMessage, MessageDocument, MessageType } from './schemas/message.schema'
import { SendMessageDto, EditMessageDto } from './dto/message.dto'
import { RoomsService } from '../rooms/rooms.service'

@Injectable()
export class MessagesService {
  constructor(
    @InjectModel(ChatMessage.name)
    private readonly model: Model<MessageDocument>,
    private readonly roomsService: RoomsService,
  ) {}

  async send(dto: SendMessageDto): Promise<MessageDocument> {
    const room = await this.roomsService.findById(dto.roomId)
    if (!room.participants.includes(dto.senderId)) {
      throw new ForbiddenException('Not a participant of this room')
    }

    const message = await this.model.create({
      roomId: dto.roomId,
      senderId: dto.senderId,
      content: dto.content,
      type: dto.type ?? MessageType.TEXT,
      metadata: dto.metadata,
      readBy: [dto.senderId],
    })

    await this.roomsService.updateLastMessage(
      dto.roomId,
      this.preview(dto.content, dto.type),
      dto.senderId,
    )
    return message
  }

  async list(roomId: string, page = 1, limit = 50) {
    const skip = (page - 1) * limit
    const [data, total] = await Promise.all([
      this.model
        .find({ roomId, deleted: false })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .exec(),
      this.model.countDocuments({ roomId, deleted: false }),
    ])
    return { data: data.reverse(), total, page, limit }
  }

  async markAsRead(messageId: string, userId: string) {
    return this.model.findByIdAndUpdate(
      messageId,
      { $addToSet: { readBy: userId } },
      { new: true },
    )
  }

  async markRoomAsRead(roomId: string, userId: string) {
    await this.model.updateMany(
      { roomId, readBy: { $ne: userId } },
      { $addToSet: { readBy: userId } },
    )
    const last = await this.model.findOne({ roomId }).sort({ createdAt: -1 })
    if (last) {
      await this.roomsService.markRead(roomId, userId, (last._id as any).toString())
    }
  }

  async edit(messageId: string, userId: string, dto: EditMessageDto) {
    const m = await this.model.findById(messageId)
    if (!m) throw new NotFoundException('Message not found')
    if (m.senderId !== userId) throw new ForbiddenException('Cannot edit others messages')
    m.content = dto.content
    m.edited = true
    await m.save()
    return m
  }

  async delete(messageId: string, userId: string) {
    const m = await this.model.findById(messageId)
    if (!m) throw new NotFoundException('Message not found')
    if (m.senderId !== userId) throw new ForbiddenException()
    m.deleted = true
    m.content = '[deleted]'
    await m.save()
  }

  private preview(content: string, type?: MessageType): string {
    if (type === MessageType.IMAGE) return '[Image]'
    if (type === MessageType.LOCATION) return '[Location]'
    return content.slice(0, 100)
  }
}
