import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { ConfigService } from '@nestjs/config'
import { Model } from 'mongoose'
import Redis from 'ioredis'
import { DriverLocation, DriverLocationDocument, DriverStatus } from '../drivers/schemas/driver-location.schema'

export interface RidePathPoint {
  lat: number
  lng: number
  timestamp: number
}

export interface ActiveRideState {
  rideId: string
  riderId: string
  driverId?: string
  status: string
  pickupLat: number
  pickupLng: number
  dropoffLat: number
  dropoffLng: number
  fare: number
  surgeMultiplier: number
  updatedAt: number
}

const RIDE_TTL_SECONDS = 60 * 60 * 4 // 4 hours
const RIDE_PATH_TTL_SECONDS = 60 * 60 * 24 // 24 hours

@Injectable()
export class TrackingService implements OnModuleDestroy {
  private readonly logger = new Logger(TrackingService.name)
  private readonly redis: Redis

  constructor(
    @InjectModel(DriverLocation.name)
    private readonly driverLocationModel: Model<DriverLocationDocument>,
    private readonly configService: ConfigService,
  ) {
    this.redis = new Redis({
      host: this.configService.get('REDIS_HOST', 'localhost'),
      port: this.configService.get<number>('REDIS_PORT', 6379),
      password: this.configService.get('REDIS_PASSWORD'),
      lazyConnect: true,
    })
    this.redis.connect().catch((err: Error) =>
      this.logger.warn(`Redis connection failed (non-fatal): ${err.message}`),
    )
  }

  async onModuleDestroy() {
    await this.redis.quit()
  }

  // ─── Driver Location (MongoDB) ────────────────────────────────────────────

  async updateDriverLocation(
    driverId: string,
    lat: number,
    lng: number,
    status?: DriverStatus,
  ): Promise<void> {
    this.logger.debug(`Updating location for driver ${driverId}: (${lat}, ${lng})`)
    await this.driverLocationModel.findOneAndUpdate(
      { driver_id: driverId },
      {
        driver_id: driverId,
        location: { type: 'Point', coordinates: [lng, lat] },
        ...(status ? { status } : {}),
        updated_at: new Date(),
      },
      { upsert: true, new: true },
    )
  }

  async getDriverLocation(driverId: string): Promise<DriverLocationDocument | null> {
    return this.driverLocationModel.findOne({ driver_id: driverId }).exec()
  }

  // ─── Active Ride State (Redis) ────────────────────────────────────────────

  async setActiveRide(state: ActiveRideState): Promise<void> {
    const key = `ride:${state.rideId}`
    await this.redis.set(key, JSON.stringify({ ...state, updatedAt: Date.now() }), 'EX', RIDE_TTL_SECONDS)
    this.logger.debug(`Cached active ride state: ${key}`)
  }

  async getActiveRide(rideId: string): Promise<ActiveRideState | null> {
    const raw = await this.redis.get(`ride:${rideId}`)
    if (!raw) return null
    return JSON.parse(raw) as ActiveRideState
  }

  async updateActiveRideStatus(rideId: string, status: string, driverId?: string): Promise<void> {
    const existing = await this.getActiveRide(rideId)
    if (!existing) return
    await this.setActiveRide({
      ...existing,
      status,
      ...(driverId ? { driverId } : {}),
    })
  }

  async deleteActiveRide(rideId: string): Promise<void> {
    await this.redis.del(`ride:${rideId}`)
  }

  // ─── Ride Path (Redis list) ───────────────────────────────────────────────

  async appendRidePathPoint(rideId: string, lat: number, lng: number): Promise<void> {
    const key = `ride:path:${rideId}`
    const point: RidePathPoint = { lat, lng, timestamp: Date.now() }
    await this.redis.rpush(key, JSON.stringify(point))
    await this.redis.expire(key, RIDE_PATH_TTL_SECONDS)
  }

  async getRidePath(rideId: string): Promise<RidePathPoint[]> {
    const raw = await this.redis.lrange(`ride:path:${rideId}`, 0, -1)
    return raw.map((item: string) => JSON.parse(item) as RidePathPoint)
  }

  async clearRidePath(rideId: string): Promise<void> {
    await this.redis.del(`ride:path:${rideId}`)
  }
}
