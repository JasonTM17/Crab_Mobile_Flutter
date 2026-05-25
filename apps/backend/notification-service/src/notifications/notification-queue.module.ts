import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { BullModule } from '@nestjs/bull'

import { NotificationsModule } from './notifications.module'
import { NotificationProcessor } from './notification.processor'
import { NotificationQueueService } from './notification-queue.service'
import { NOTIFICATION_FANOUT_QUEUE } from './notification-queue.constants'

/**
 * BullMQ-backed fanout queue. Producers (any service that wants to push a
 * notification) call NotificationQueueService.enqueue() and return — the
 * actual delivery (push token lookup, FCM call, in-app insert, etc.) happens
 * in the {@link NotificationProcessor}.
 *
 * Hot-path benefits:
 *   - producers don't block on FCM,
 *   - retries on transient FCM/SMTP errors are automatic,
 *   - bulk fanout (promo to N users) is cheap.
 */
@Module({
  imports: [
    NotificationsModule,
    BullModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        redis: config.get<string>('REDIS_URL') ?? 'redis://localhost:6379',
      }),
    }),
    BullModule.registerQueue({
      name: NOTIFICATION_FANOUT_QUEUE,
      defaultJobOptions: {
        attempts: 5,
        backoff: { type: 'exponential', delay: 1000 },
        removeOnComplete: { age: 6 * 3600, count: 5000 },
        removeOnFail: { age: 24 * 3600 },
      },
    }),
  ],
  providers: [NotificationProcessor, NotificationQueueService],
  exports: [NotificationQueueService],
})
export class NotificationQueueModule {}
