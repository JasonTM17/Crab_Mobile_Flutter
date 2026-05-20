import { Process, Processor, OnQueueFailed, OnQueueCompleted } from '@nestjs/bull'
import { Injectable, Logger } from '@nestjs/common'
import type { Job } from 'bull'

import { NotificationsService } from './notifications.service'
import {
  NotificationType,
  NotificationChannel,
} from './schemas/notification.schema'
import { NOTIFICATION_FANOUT_QUEUE } from './notification-queue.module'
import type { NotificationFanoutJob } from './notification-queue.service'

const TYPE_MAP: Record<NotificationFanoutJob['type'], NotificationType> = {
  ride: NotificationType.RIDE,
  food: NotificationType.ORDER,
  payment: NotificationType.SYSTEM,
  promo: NotificationType.PROMO,
  chat: NotificationType.CHAT,
  system: NotificationType.SYSTEM,
}

const CHANNEL_MAP: Record<string, NotificationChannel> = {
  push: NotificationChannel.PUSH,
  inapp: NotificationChannel.IN_APP,
  email: NotificationChannel.EMAIL,
  sms: NotificationChannel.SMS,
}

/**
 * Consumes fanout jobs and dispatches via the public `send()` API which
 * already handles per-user preferences + per-channel delivery + token pruning.
 *
 * Concurrency: 16 — most cost is HTTP to FCM/SMTP, so a deeper pool than
 * ride-matching makes sense.
 */
@Injectable()
@Processor(NOTIFICATION_FANOUT_QUEUE)
export class NotificationProcessor {
  private readonly logger = new Logger(NotificationProcessor.name)

  constructor(private readonly notifications: NotificationsService) {}

  @Process({ name: 'fanout', concurrency: 16 })
  async run(job: Job<NotificationFanoutJob>) {
    const { userId, type, title, body, channels, data, key } = job.data
    const t0 = Date.now()

    const mappedChannels = channels
      .map((c) => CHANNEL_MAP[c])
      .filter((c): c is NotificationChannel => Boolean(c))

    await this.notifications.send({
      userId,
      title,
      body,
      type: TYPE_MAP[type] ?? NotificationType.SYSTEM,
      channels: mappedChannels.length > 0 ? mappedChannels : undefined,
      data,
    })

    const elapsedMs = Date.now() - t0
    this.logger.log(
      `fanout user=${userId} type=${type} key=${key} elapsed_ms=${elapsedMs}`,
    )
    return { userId, elapsedMs }
  }

  @OnQueueCompleted()
  onCompleted(job: Job<NotificationFanoutJob>) {
    this.logger.debug(`done job=${job.id} user=${job.data.userId}`)
  }

  @OnQueueFailed()
  onFailed(job: Job<NotificationFanoutJob>, err: Error) {
    this.logger.error(
      `failed job=${job.id} user=${job.data.userId} attempts=${job.attemptsMade}: ${err.message}`,
    )
  }
}
