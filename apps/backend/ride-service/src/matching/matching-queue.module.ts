import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { BullModule } from '@nestjs/bull'

import { DriversModule } from '../drivers/drivers.module'
import { FareModule } from '../fare/fare.module'
import { MatchingService } from './matching.service'
import { MatchingProcessor } from './matching.processor'
import { MatchingQueueService } from './matching-queue.service'
import { RIDE_MATCHING_QUEUE } from './matching-queue.constants'

/**
 * BullMQ-backed matching queue. Producers (rides controller / service) push
 * a job per new ride request; the {@link MatchingProcessor} consumes them
 * and runs the weighted-score matcher off the request hot-path.
 *
 * Concurrency tuned for short tasks (<1s each). Dead jobs are retained so
 * ops can inspect failures via Bull dashboard or Redis directly.
 */
@Module({
  imports: [
    DriversModule,
    FareModule,
    BullModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        redis: config.get<string>('REDIS_URL') ?? 'redis://localhost:6379',
      }),
    }),
    BullModule.registerQueue({
      name: RIDE_MATCHING_QUEUE,
      defaultJobOptions: {
        attempts: 3,
        backoff: { type: 'exponential', delay: 500 },
        removeOnComplete: { age: 3600, count: 1000 },
        removeOnFail: { age: 24 * 3600 },
      },
    }),
  ],
  providers: [MatchingService, MatchingProcessor, MatchingQueueService],
  exports: [MatchingService, MatchingQueueService],
})
export class MatchingQueueModule {}
