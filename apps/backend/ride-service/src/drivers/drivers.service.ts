import { Injectable, Logger } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import {
  DriverLocation,
  DriverLocationDocument,
  DriverStatus,
  VehicleType,
} from './schemas/driver-location.schema'

export interface NearbyDriver {
  driver_id: string
  distance_m: number
  rating: number
  vehicle_type: VehicleType
  status: DriverStatus
  location: { lat: number; lng: number }
}

@Injectable()
export class DriversService {
  private readonly logger = new Logger(DriversService.name)

  constructor(
    @InjectModel(DriverLocation.name)
    private readonly driverLocationModel: Model<DriverLocationDocument>,
  ) {}

  async findNearbyDrivers(
    lat: number,
    lng: number,
    radiusMeters = 3000,
    vehicleType?: VehicleType,
  ): Promise<NearbyDriver[]> {
    const filter: Record<string, unknown> = {
      status: DriverStatus.ONLINE,
      location: {
        $nearSphere: {
          $geometry: { type: 'Point', coordinates: [lng, lat] },
          $maxDistance: radiusMeters,
        },
      },
    }

    if (vehicleType) {
      filter['vehicle_type'] = vehicleType
    }

    const docs = await this.driverLocationModel.find(filter).limit(20).exec()

    return docs.map((doc) => ({
      driver_id: doc.driver_id,
      distance_m: 0, // populated by caller if needed
      rating: doc.rating,
      vehicle_type: doc.vehicle_type,
      status: doc.status,
      location: {
        lat: doc.location.coordinates[1],
        lng: doc.location.coordinates[0],
      },
    }))
  }

  async setDriverStatus(driverId: string, status: DriverStatus): Promise<void> {
    await this.driverLocationModel
      .findOneAndUpdate(
        { driver_id: { $eq: driverId } },
        {
          $set: { status, updated_at: new Date() },
          $setOnInsert: {
            driver_id: driverId,
            location: { type: 'Point', coordinates: [106.7009, 10.7769] },
            vehicle_type: VehicleType.MOTORBIKE,
            rating: 5.0,
          },
        },
        { upsert: true },
      )
      .exec()
  }

  async updateLocation(
    driverId: string,
    latitude: number,
    longitude: number,
    status?: DriverStatus,
  ): Promise<void> {
    await this.driverLocationModel
      .findOneAndUpdate(
        { driver_id: { $eq: driverId } },
        {
          $set: {
            location: { type: 'Point', coordinates: [longitude, latitude] },
            ...(status ? { status } : {}),
            updated_at: new Date(),
          },
          $setOnInsert: {
            driver_id: driverId,
            vehicle_type: VehicleType.MOTORBIKE,
            rating: 5.0,
          },
        },
        { upsert: true },
      )
      .exec()
  }

  async countOnlineDrivers(): Promise<number> {
    return this.driverLocationModel.countDocuments({ status: DriverStatus.ONLINE }).exec()
  }
}
