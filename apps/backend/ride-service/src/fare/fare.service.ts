import { Injectable } from '@nestjs/common'

export enum VehicleType {
  BIKE = 'BIKE',
  CAR_4 = 'CAR_4',
  CAR_7 = 'CAR_7',
  PREMIUM = 'PREMIUM',
}

export interface FareConfig {
  baseFare: number
  perKm: number
  perMin: number
  minFare: number
}

export interface FareEstimate {
  vehicleType: VehicleType
  distance_km: number
  duration_min: number
  base_fare: number
  distance_fare: number
  time_fare: number
  surge_multiplier: number
  total_fare: number
}

const FARE_CONFIG: Record<VehicleType, FareConfig> = {
  [VehicleType.BIKE]: { baseFare: 10000, perKm: 4000, perMin: 500, minFare: 12000 },
  [VehicleType.CAR_4]: { baseFare: 20000, perKm: 11000, perMin: 1500, minFare: 25000 },
  [VehicleType.CAR_7]: { baseFare: 25000, perKm: 13000, perMin: 1800, minFare: 30000 },
  [VehicleType.PREMIUM]: { baseFare: 40000, perKm: 18000, perMin: 2500, minFare: 50000 },
}

const AVG_SPEED_KMH = 25 // Vietnam city avg speed
const EARTH_RADIUS_KM = 6371

@Injectable()
export class FareService {
  /**
   * Haversine distance in kilometers.
   */
  calculateDistance(
    lat1: number,
    lng1: number,
    lat2: number,
    lng2: number,
  ): number {
    const toRad = (deg: number) => (deg * Math.PI) / 180
    const dLat = toRad(lat2 - lat1)
    const dLng = toRad(lng2 - lng1)
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return EARTH_RADIUS_KM * c
  }

  estimate(
    pickupLat: number,
    pickupLng: number,
    dropoffLat: number,
    dropoffLng: number,
    surgeMultiplier = 1.0,
    vehicleType: VehicleType = VehicleType.BIKE,
  ): FareEstimate {
    const distance_km = this.calculateDistance(
      pickupLat,
      pickupLng,
      dropoffLat,
      dropoffLng,
    )
    const duration_min = (distance_km / AVG_SPEED_KMH) * 60

    const config = FARE_CONFIG[vehicleType]
    const base_fare = config.baseFare
    const distance_fare = distance_km * config.perKm
    const time_fare = duration_min * config.perMin
    const subtotal = base_fare + distance_fare + time_fare
    const total = Math.max(subtotal * surgeMultiplier, config.minFare)

    return {
      vehicleType,
      distance_km: Math.round(distance_km * 100) / 100,
      duration_min: Math.round(duration_min),
      base_fare,
      distance_fare: Math.round(distance_fare),
      time_fare: Math.round(time_fare),
      surge_multiplier: surgeMultiplier,
      total_fare: Math.round(total),
    }
  }

  /**
   * Surge calculation:
   * - ratio = activeRequests / onlineDrivers
   * - 1.0 if ratio < 0.5
   * - 1.2 if 0.5-1.0
   * - 1.5 if 1.0-2.0
   * - 2.0 if > 2.0
   */
  calculateSurge(activeRequests: number, onlineDrivers: number): number {
    if (onlineDrivers === 0) return 2.0
    const ratio = activeRequests / onlineDrivers
    if (ratio < 0.5) return 1.0
    if (ratio < 1.0) return 1.2
    if (ratio < 2.0) return 1.5
    return 2.0
  }

  /**
   * Estimate for all vehicle types at once.
   */
  estimateAllTypes(
    pickupLat: number,
    pickupLng: number,
    dropoffLat: number,
    dropoffLng: number,
    surgeMultiplier = 1.0,
  ): FareEstimate[] {
    return Object.values(VehicleType).map((vt) =>
      this.estimate(pickupLat, pickupLng, dropoffLat, dropoffLng, surgeMultiplier, vt),
    )
  }
}
