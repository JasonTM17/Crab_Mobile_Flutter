import { Injectable } from '@nestjs/common'

/**
 * Haversine formula — returns distance in km between two lat/lng points.
 */
function haversineKm(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371
  const dLat = ((lat2 - lat1) * Math.PI) / 180
  const dLng = ((lng2 - lng1) * Math.PI) / 180
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

export interface FareEstimate {
  distance_km: number
  duration_min: number
  base_fare: number
  distance_fare: number
  surge_multiplier: number
  total_fare: number
}

@Injectable()
export class FareService {
  private readonly BASE_FARE = 12000 // VND
  private readonly RATE_FIRST_2KM = 5000 // VND/km
  private readonly RATE_AFTER_2KM = 4000 // VND/km
  private readonly WAITING_RATE = 500 // VND/min
  private readonly SURGE_MIN = 1.0
  private readonly SURGE_MAX = 3.0

  calculateDistance(
    pickupLat: number,
    pickupLng: number,
    dropoffLat: number,
    dropoffLng: number,
  ): number {
    return haversineKm(pickupLat, pickupLng, dropoffLat, dropoffLng)
  }

  calculateDistanceFare(distanceKm: number): number {
    if (distanceKm <= 2) {
      return distanceKm * this.RATE_FIRST_2KM
    }
    return 2 * this.RATE_FIRST_2KM + (distanceKm - 2) * this.RATE_AFTER_2KM
  }

  calculateSurge(activeRequests: number, availableDrivers: number): number {
    if (availableDrivers === 0) return this.SURGE_MAX
    const ratio = activeRequests / availableDrivers
    return Math.min(Math.max(ratio, this.SURGE_MIN), this.SURGE_MAX)
  }

  estimate(
    pickupLat: number,
    pickupLng: number,
    dropoffLat: number,
    dropoffLng: number,
    surgeMultiplier = 1.0,
    waitingMinutes = 0,
  ): FareEstimate {
    const distance_km = this.calculateDistance(pickupLat, pickupLng, dropoffLat, dropoffLng)
    // Rough estimate: avg 30 km/h in city
    const duration_min = Math.ceil((distance_km / 30) * 60)
    const distance_fare = this.calculateDistanceFare(distance_km)
    const waiting_fare = waitingMinutes * this.WAITING_RATE
    const subtotal = this.BASE_FARE + distance_fare + waiting_fare
    const total_fare = Math.round(subtotal * surgeMultiplier)

    return {
      distance_km: Math.round(distance_km * 100) / 100,
      duration_min,
      base_fare: this.BASE_FARE,
      distance_fare: Math.round(distance_fare),
      surge_multiplier: surgeMultiplier,
      total_fare,
    }
  }
}
