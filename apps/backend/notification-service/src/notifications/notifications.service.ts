import { Injectable } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import { Notification, NotificationDocument, NotificationType } from './schemas/notification.schema'

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(Notification.name)
    private readonly notificationModel: Model<NotificationDocument>,
  ) {}

  async create(userId: string, title: string, body: string, type: NotificationType, data?: Record<string, any>) {
    return this.notificationModel.create({
      user_id: userId,
      title,
      body,
      type,
      data,
    })
  }

  async getByUser(userId: string, limit = 30, offset = 0) {
    return this.notificationModel
      .find({ user_id: userId })
      .sort({ sent_at: -1 })
      .skip(offset)
      .limit(limit)
      .exec()
  }

  async getUnreadCount(userId: string): Promise<number> {
    return this.notificationModel.countDocuments({ user_id: userId, is_read: false })
  }

  async markAsRead(id: string) {
    return this.notificationModel.findByIdAndUpdate(id, { is_read: true })
  }

  async markAllAsRead(userId: string) {
    return this.notificationModel.updateMany(
      { user_id: userId, is_read: false },
      { is_read: true },
    )
  }
}
