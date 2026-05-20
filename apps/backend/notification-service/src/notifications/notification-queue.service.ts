import { Inject, Injectable, Logger } from '@nestjs/common'
import { InjectQueue } from '@nestjs/bull'
import type { Queue } from 'bull'

import { NOTIFICATION_FANOUT_QUEUE } from './notification-queue.module'

export type NotificationChannel = 'push' | 'inapp' | 'email' | 'sms'

export interface NotificationFanoutJob {
  /** Idempotency key - producer-supplied to dedupe at the queue level. */
  key: string
  userId: string
  type: 'ride' | 'food' | 'payment' | 'promo' | 'chat' | 'system'
  title: string
  body: string
  channels: NotificationChannel[]
  /** Free-form payload for client deep-linking (rideId, orderId, etc). */
  data?: Record<string, unknown>
}

/**
 * Producer wrapper around the notification fanout queue.
 *
 * Use enqueue() instead of calling NotificationsService directly when:
 *   - the call is non-blocking (fire-and-forget),
 *   - the call is part of a fanout (one event → many users),
 *   - or the call is on a request path you can't afford to slow down.
 */
@Injectable()
export class NotificationQueueService {
  private readonly logger = new Logger(NotificationQueueService.name)

  constructor(
    @InjectQueue(NOTIFICATION_FANOUT_QUEUE)
    private readonly queue: Queue<NotificationFanoutJob>,
  ) {}

  async enqueue(job: NotificationFanoutJob, delayMs = 0) {
    await this.queue.add('fanout', job, {
      jobId: job.key,
      delay: delayMs,
    })
    this.logger.log(`enqueued fanout user=${job.userId} type=${job.type}`)
  }

  /** Bulk enqueue for broadcast scenarios (promo to N users). */
  async enqueueBulk(jobs: NotificationFanoutJob[]) {
    if (jobs.length === 0) return
    await this.queue.addBulk(
      jobs.map((j) => ({
        name: 'fanout',
        data: j,
        opts: { jobId: j.key },
      })),
    )
    this.logger.log(`bulk enqueue ${jobs.length} fanout jobs`)
  }
}
