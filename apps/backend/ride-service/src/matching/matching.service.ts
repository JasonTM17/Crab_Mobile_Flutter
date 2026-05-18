import { Injectable, Logger } from '@nestjs/common'
import { DriversService } from '../drivers/drivers.service'
import { FareService } from '../fare/fare.service'

export interface MatchResult {
  driver_id: string
  score: number
  distance_m: number
  rating: number
}

@Injectable()
export class MatchingService {
  private readonly logger = new Logger(MatchingService.name)
  private readonly DISTANCE_WEIGHT = 0.7
  private readonly RATING_WEIGHT = 0.3
  private readonly SEARCH_RADIUS_M = 3000

  constructor(
    private readonly driversService: DriversService,
    private readonly fareService: FareService,
  ) {}

  /**
   * Find and rank nearby drivers using weighted score:
   * score = 0.7 * (1 - normalized_distance) + 0.3 * normalized_rating
   * Higher score = better match.
   */
  async findBestDriver(
    pickupLat: number,
    pickupLng: number,
  ): Promise<MatchResult | null> {
    const nearby = await this.driversService.findNearbyDrivers(
      pickupLat,
      pickupLng,
      this.SEARCH_RADIUS_M,
    )

    if (nearby.length === 0) {
      this.logger.warn(`No drivers found within ${this.SEARCH_RADIUS_M}m of (${pickupLat}, ${pickupLng})`)
      return null
    }

    // Compute actual distances using haversine
    const withDistances = nearby.map((driver) => {
      const distKm = this.fareService.calculateDistance(
        pickupLat,
        pickupLng,
        driver.location.lat,
        driver.location.lng,
      )
      return { ...driver, distance_m: Math.round(distKm * 1000) }
    })

    const maxDist = Math.max(...withDistances.map((d) => d.distance_m), 1)
    const minRating = 1.0
    const maxRating = 5.0

    const scored: MatchResult[] = withDistances.map((driver) => {
      const normalizedDist = driver.distance_m / maxDist
      const normalizedRating = (driver.rating - minRating) / (maxRating - minRating)
      const score =
        this.DISTANCE_WEIGHT * (1 - normalizedDist) +
        this.RATING_WEIGHT * normalizedRating

      return {
        driver_id: driver.driver_id,
        score,
        distance_m: driver.distance_m,
        rating: driver.rating,
      }
    })

    // Sort descending by score
    scored.sort((a, b) => b.score - a.score)
    return scored[0] ?? null
  }

  async findRankedDrivers(
    pickupLat: number,
    pickupLng: number,
    limit = 5,
  ): Promise<MatchResult[]> {
    const nearby = await this.driversService.findNearbyDrivers(
      pickupLat,
      pickupLng,
      this.SEARCH_RADIUS_M,
    )

    if (nearby.length === 0) return []

    const withDistances = nearby.map((driver) => {
      const distKm = this.fareService.calculateDistance(
        pickupLat,
        pickupLng,
        driver.location.lat,
        driver.location.lng,
      )
      return { ...driver, distance_m: Math.round(distKm * 1000) }
    })

    const maxDist = Math.max(...withDistances.map((d) => d.distance_m), 1)

    const scored: MatchResult[] = withDistances.map((driver) => {
      const normalizedDist = driver.distance_m / maxDist
      const normalizedRating = (driver.rating - 1.0) / 4.0
      const score =
        this.DISTANCE_WEIGHT * (1 - normalizedDist) +
        this.RATING_WEIGHT * normalizedRating

      return {
        driver_id: driver.driver_id,
        score,
        distance_m: driver.distance_m,
        rating: driver.rating,
      }
    })

    scored.sort((a, b) => b.score - a.score)
    return scored.slice(0, limit)
  }
}
