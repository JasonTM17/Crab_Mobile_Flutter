import { Process, Processor, OnQueueFailed, OnQueueCompleted } from '@nestjs/bull'
import { Injectable, Logger } from '@nestjs/common'
import type { Job } from 'bull'

import { MatchingService } from './matching.service'
import { RIDE_MATCHING_QUEUE } from './matching-queue.constants'
import type { RideMatchJob } from './matching-queue.service'

/**
 * Consumes ride-matching jobs out of Redis and runs the scoring algorithm
 * off the HTTP hot-path. Returns the picked driver or null so the upstream
 * orchestrator can react (offer to driver, retry, surge price, etc.).
 *
 * Concurrency: 8 — matching is CPU-light and IO-bound (one Mongo geo query
 * + one Postgres read), so we can comfortably overlap across the pool.
 */
@Injectable()
@Processor(RIDE_MATCHING_QUEUE)
export class MatchingProcessor {
  private readonly logger = new Logger(MatchingProcessor.name)

  constructor(private readonly matching: MatchingService) {}

  @Process({ name: 'match', concurrency: 8 })
  async run(job: Job<RideMatchJob>) {
    const { rideId, pickupLat, pickupLng, excludeDriverIds = [] } = job.data
    const t0 = Date.now()

    const result = await this.matching.findBestDriver(
      pickupLat,
      pickupLng,
      excludeDriverIds,
    )
    const elapsedMs = Date.now() - t0

    if (!result) {
      this.logger.warn(
        `match miss ride=${rideId} elapsed_ms=${elapsedMs} attempt=${job.attemptsMade + 1}`,
      )
      return { rideId, matched: false, elapsedMs }
    }

    this.logger.log(
      `match hit ride=${rideId} driver=${result.driver_id} score=${result.score.toFixed(3)} elapsed_ms=${elapsedMs}`,
    )
    return { rideId, matched: true, driverId: result.driver_id, elapsedMs }
  }

  @OnQueueCompleted()
  onCompleted(job: Job<RideMatchJob>) {
    this.logger.debug(`done job=${job.id} ride=${job.data.rideId}`)
  }

  @OnQueueFailed()
  onFailed(job: Job<RideMatchJob>, err: Error) {
    this.logger.error(
      `failed job=${job.id} ride=${job.data.rideId} attempts=${job.attemptsMade}: ${err.message}`,
    )
  }
}
