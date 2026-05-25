import { Inject, Injectable, Logger } from '@nestjs/common'
import { InjectQueue } from '@nestjs/bull'
import type { Queue } from 'bull'

import { RIDE_MATCHING_QUEUE } from './matching-queue.constants'

export interface RideMatchJob {
  rideId: string
  pickupLat: number
  pickupLng: number
  vehicleType: 'bike' | 'car' | 'sedan' | 'suv'
  excludeDriverIds?: string[]
  /** Idempotency anchor: skip enqueue if a job with this id already exists. */
  jobKey?: string
}

/**
 * Thin producer wrapper around the matching queue.
 *
 * Consumers (controllers, sagas) call enqueue() with a {@link RideMatchJob}
 * payload and never block on the actual matching work — the
 * {@link MatchingProcessor} consumes from Redis.
 */
@Injectable()
export class MatchingQueueService {
  private readonly logger = new Logger(MatchingQueueService.name)

  constructor(
    @InjectQueue(RIDE_MATCHING_QUEUE) private readonly queue: Queue<RideMatchJob>,
  ) {}

  async enqueue(job: RideMatchJob, delayMs = 0) {
    const opts = {
      jobId: job.jobKey ?? `match:${job.rideId}`,
      delay: delayMs,
    }
    await this.queue.add('match', job, opts)
    this.logger.log(`enqueued match job for ride ${job.rideId}`)
  }

  /** Re-queue with a back-off when the first match attempt found no driver. */
  async retryAfter(rideId: string, ms: number, payload: RideMatchJob) {
    await this.queue.add('match', payload, {
      jobId: `match:${rideId}:retry-${Date.now()}`,
      delay: ms,
      attempts: 1,
    })
    this.logger.log(`retry match job for ride ${rideId} in ${ms}ms`)
  }
}
