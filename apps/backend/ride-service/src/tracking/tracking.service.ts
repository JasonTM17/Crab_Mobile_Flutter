import { Injectable, Logger } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import { DriverLocation, DriverLocationDocument, DriverStatus } from '../drivers/schemas/driver-location.schema'

export interface RidePathPoint {
  lat: number
  lng: number
  timestamp: number
}

@Injectable()
export class TrackingService {
  private readonly logger = new Logger(TrackingService.name)
  // In-memory ride path store (replace with Redis in production)
  private readonly ridePaths = new Map<string, RidePathPoint[]>()

  constructor(
    @InjectModel(DriverLocation.name)
    private readonly driverLocationModel: Model<DriverLocationDocument>,
  ) {}

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

  appendRidePathPoint(rideId: string, lat: number, lng: number): void {
    const path = this.ridePaths.get(rideId) ?? []
    path.push({ lat, lng, timestamp: Date.now() })
    this.ridePaths.set(rideId, path)
  }

  getRidePath(rideId: string): RidePathPoint[] {
    return this.ridePaths.get(rideId) ?? []
  }

  clearRidePath(rideId: string): void {
    this.ridePaths.delete(rideId)
  }
}
