import { Injectable, Logger } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import {
  Notification,
  NotificationDocument,
  NotificationChannel,
  NotificationType,
} from './schemas/notification.schema'
import { CreateNotificationDto, BroadcastDto } from './dto/notification.dto'
import {
  NotificationPreferences,
  PreferencesDocument,
} from '../preferences/schemas/preferences.schema'
import { FcmService } from './fcm.service'

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name)

  constructor(
    @InjectModel(Notification.name)
    private readonly model: Model<NotificationDocument>,
    @InjectModel(NotificationPreferences.name)
    private readonly prefsModel: Model<PreferencesDocument>,
    private readonly fcm: FcmService,
  ) {}

  async send(dto: CreateNotificationDto): Promise<NotificationDocument> {
    const prefs = await this.getOrCreatePreferences(dto.userId)
    if (!this.isAllowed(prefs, dto.type)) {
      this.logger.debug(`Notification suppressed by preferences for user ${dto.userId}`)
    }

    const channels = dto.channels ?? this.defaultChannels(prefs)

    const notif = await this.model.create({
      userId: dto.userId,
      title: dto.title,
      body: dto.body,
      type: dto.type,
      channels,
      data: dto.data,
      imageUrl: dto.imageUrl,
      deepLink: dto.deepLink,
    })

    this.deliver(notif, prefs).catch((e) =>
      this.logger.error(`Delivery failed: ${e.message}`),
    )

    return notif
  }

  async broadcast(dto: BroadcastDto) {
    const docs = dto.userIds.map((uid) => ({
      userId: uid,
      title: dto.title,
      body: dto.body,
      type: dto.type,
      data: dto.data,
      imageUrl: dto.imageUrl,
      deepLink: dto.deepLink,
      channels: ['in_app', 'push'],
    }))
    await this.model.insertMany(docs)
    this.logger.log(`Broadcast to ${dto.userIds.length} users`)
    return { sent: dto.userIds.length }
  }

  async list(userId: string, page = 1, limit = 30, unreadOnly = false) {
    const filter: any = { userId }
    if (unreadOnly) filter.read = false
    const skip = (page - 1) * limit
    const [data, total, unreadCount] = await Promise.all([
      this.model.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).exec(),
      this.model.countDocuments(filter),
      this.model.countDocuments({ userId, read: false }),
    ])
    return { data, total, unreadCount, page, limit }
  }

  async markRead(notificationId: string, userId: string) {
    return this.model.findOneAndUpdate(
      { _id: notificationId, userId },
      { read: true, readAt: new Date() },
      { new: true },
    )
  }

  async markAllRead(userId: string) {
    const result = await this.model.updateMany(
      { userId, read: false },
      { read: true, readAt: new Date() },
    )
    return { updated: result.modifiedCount }
  }

  async unreadCount(userId: string) {
    return this.model.countDocuments({ userId, read: false })
  }

  async delete(notificationId: string, userId: string): Promise<{ acknowledged: boolean; deletedCount: number }> {
    const result = await this.model.deleteOne({ _id: notificationId, userId })
    return { acknowledged: result.acknowledged, deletedCount: result.deletedCount }
  }

  private async getOrCreatePreferences(userId: string): Promise<PreferencesDocument> {
    let prefs = await this.prefsModel.findOne({ userId })
    if (!prefs) {
      prefs = await this.prefsModel.create({ userId })
    }
    return prefs
  }

  private isAllowed(prefs: PreferencesDocument, type: NotificationType): boolean {
    switch (type) {
      case NotificationType.RIDE:
        return prefs.rideEnabled
      case NotificationType.ORDER:
        return prefs.orderEnabled
      case NotificationType.CHAT:
        return prefs.chatEnabled
      case NotificationType.PROMO:
        return prefs.promoEnabled
      default:
        return prefs.systemEnabled
    }
  }

  private defaultChannels(prefs: PreferencesDocument): NotificationChannel[] {
    const channels: NotificationChannel[] = [NotificationChannel.IN_APP]
    if (prefs.pushEnabled) channels.push(NotificationChannel.PUSH)
    return channels
  }

  private async deliver(notif: NotificationDocument, prefs: PreferencesDocument) {
    if (notif.channels.includes(NotificationChannel.PUSH) && prefs.fcmTokens.length > 0) {
      const result = await this.fcm.sendToTokens(
        prefs.fcmTokens,
        {
          title: notif.title,
          body: notif.body,
          imageUrl: notif.imageUrl,
        },
        {
          ...(notif.data ? { ...notif.data } : {}),
          ...(notif.deepLink ? { deepLink: notif.deepLink } : {}),
          type: String(notif.type),
        },
      )
      if (result.invalidTokens.length > 0) {
        // Strip invalid tokens from preferences
        await this.prefsModel.updateOne(
          { userId: notif.userId },
          { $pull: { fcmTokens: { $in: result.invalidTokens } } },
        )
        this.logger.debug(
          `Pruned ${result.invalidTokens.length} invalid FCM tokens for user ${notif.userId}`,
        )
      }
      this.logger.debug(
        `[FCM] Sent to user ${notif.userId}: ${result.successCount}/${prefs.fcmTokens.length} ok`,
      )
    }
    notif.delivered = true
    notif.deliveredAt = new Date()
    await notif.save()
  }
}
