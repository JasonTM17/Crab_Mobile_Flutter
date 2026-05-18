import { Injectable, NotFoundException } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import { ChatRoom, RoomDocument, RoomStatus } from './schemas/room.schema'
import { CreateRoomDto } from './dto/room.dto'

@Injectable()
export class RoomsService {
  constructor(
    @InjectModel(ChatRoom.name)
    private readonly roomModel: Model<RoomDocument>,
  ) {}

  async create(dto: CreateRoomDto): Promise<RoomDocument> {
    if (dto.referenceId) {
      const existing = await this.roomModel.findOne({
        referenceId: dto.referenceId,
        type: dto.type,
        status: RoomStatus.ACTIVE,
      })
      if (existing) return existing
    }

    const unreadCount: Record<string, number> = {}
    for (const p of dto.participants) unreadCount[p] = 0

    const room = await this.roomModel.create({
      type: dto.type,
      participants: dto.participants,
      referenceId: dto.referenceId,
      unreadCount,
      lastReadMessageId: {},
    })
    return room
  }

  async findById(id: string): Promise<RoomDocument> {
    const room = await this.roomModel.findById(id).exec()
    if (!room) throw new NotFoundException(`Room ${id} not found`)
    return room
  }

  async listForUser(userId: string, status: RoomStatus = RoomStatus.ACTIVE) {
    return this.roomModel
      .find({ participants: userId, status })
      .sort({ lastMessageAt: -1, createdAt: -1 })
      .limit(100)
      .exec()
  }

  async archive(id: string) {
    return this.roomModel.findByIdAndUpdate(
      id,
      { status: RoomStatus.ARCHIVED },
      { new: true },
    )
  }

  async findByReference(referenceId: string) {
    return this.roomModel.findOne({ referenceId })
  }

  async updateLastMessage(roomId: string, preview: string, senderId: string) {
    const room = await this.roomModel.findById(roomId)
    if (!room) return
    const update: any = {
      lastMessageAt: new Date(),
      lastMessagePreview: preview.slice(0, 100),
    }
    for (const p of room.participants) {
      if (p !== senderId) {
        update[`unreadCount.${p}`] = (room.unreadCount?.[p] ?? 0) + 1
      }
    }
    await this.roomModel.updateOne({ _id: roomId }, { $set: update })
  }

  async markRead(roomId: string, userId: string, lastMessageId: string) {
    await this.roomModel.updateOne(
      { _id: roomId },
      {
        $set: {
          [`unreadCount.${userId}`]: 0,
          [`lastReadMessageId.${userId}`]: lastMessageId,
        },
      },
    )
  }
}
