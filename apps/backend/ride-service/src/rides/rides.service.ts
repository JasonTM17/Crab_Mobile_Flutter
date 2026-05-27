import { Injectable, NotFoundException, Logger } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Between, FindOptionsWhere, Repository } from 'typeorm'
import { RideEntity } from './entities/ride.entity'
import { CreateRideDto } from './dto/create-ride.dto'
import { UpdateRideStatusDto } from './dto/update-ride-status.dto'
import { FareService } from '../fare/fare.service'
import { MatchingService } from '../matching/matching.service'
import { DriversService } from '../drivers/drivers.service'
import { RideStatus } from '@crab/common-types'
import { DriverStatus } from '../drivers/schemas/driver-location.schema'

export interface RideListOptions {
  page?: number
  limit?: number
  status?: RideStatus
  fromDate?: Date
  toDate?: Date
}

@Injectable()
export class RidesService {
  private readonly logger = new Logger(RidesService.name)

  constructor(
    @InjectRepository(RideEntity)
    private readonly rideRepository: Repository<RideEntity>,
    private readonly fareService: FareService,
    private readonly matchingService: MatchingService,
    private readonly driversService: DriversService,
  ) {}

  async create(dto: CreateRideDto): Promise<RideEntity> {
    // Get surge multiplier based on current demand
    const onlineDrivers = await this.driversService.countOnlineDrivers()
    // Count active requests (REQUESTED + MATCHED)
    const activeRequests = await this.rideRepository.count({
      where: [{ status: RideStatus.REQUESTED }, { status: RideStatus.MATCHED }],
    })
    const surgeMultiplier = this.fareService.calculateSurge(activeRequests, onlineDrivers)

    // Calculate fare estimate
    const estimate = this.fareService.estimate(
      dto.pickup_lat,
      dto.pickup_lng,
      dto.dropoff_lat,
      dto.dropoff_lng,
      surgeMultiplier,
      dto.vehicle_type,
    )

    const ride = this.rideRepository.create({
      rider_id: dto.rider_id,
      pickup_lat: dto.pickup_lat,
      pickup_lng: dto.pickup_lng,
      pickup_address: dto.pickup_address,
      dropoff_lat: dto.dropoff_lat,
      dropoff_lng: dto.dropoff_lng,
      dropoff_address: dto.dropoff_address,
      status: RideStatus.REQUESTED,
      fare: estimate.total_fare,
      distance_km: estimate.distance_km,
      duration_min: estimate.duration_min,
      surge_multiplier: surgeMultiplier,
      vehicle_type: dto.vehicle_type ?? estimate.vehicleType,
    })

    const saved = await this.rideRepository.save(ride)
    this.logger.log(`Ride created: ${saved.id} for rider ${dto.rider_id}`)

    // Attempt driver matching asynchronously
    this.matchDriver(saved).catch((err) =>
      this.logger.error(`Driver matching failed for ride ${saved.id}: ${err.message}`),
    )

    return saved
  }

  async acceptRide(rideId: string, driverId: string): Promise<RideEntity> {
    const ride = await this.findById(rideId)
    if (ride.status !== RideStatus.REQUESTED && ride.status !== RideStatus.MATCHED) {
      throw new Error(`Ride cannot be accepted in status ${ride.status}`)
    }
    if (ride.driver_id && ride.driver_id !== driverId) {
      throw new Error('Ride already assigned to another driver')
    }
    await this.rideRepository.update(rideId, {
      driver_id: driverId,
      status: RideStatus.MATCHED,
      accepted_at: new Date(),
    })
    await this.driversService.setDriverStatus(driverId, DriverStatus.BUSY)
    this.logger.log(`Ride ${rideId} accepted by driver ${driverId}`)
    return this.findById(rideId)
  }

  async rejectRide(rideId: string, driverId: string): Promise<RideEntity> {
    const ride = await this.findById(rideId)
    if (ride.driver_id !== driverId) {
      throw new Error('Driver not assigned to this ride')
    }
    // Reset to REQUESTED and trigger re-matching, excluding this driver
    await this.rideRepository.update(rideId, {
      driver_id: null as unknown as string,
      status: RideStatus.REQUESTED,
    })
    await this.driversService.setDriverStatus(driverId, DriverStatus.ONLINE)
    this.logger.log(`Ride ${rideId} rejected by driver ${driverId}, re-matching`)
    // Async re-match excluding this driver
    void this.matchDriver(await this.findById(rideId), [driverId]).catch((err) =>
      this.logger.error(`Re-match failed for ride ${rideId}: ${err.message}`),
    )
    return this.findById(rideId)
  }

  private async matchDriver(ride: RideEntity, excludeDriverIds: string[] = []): Promise<void> {
    const match = await this.matchingService.findBestDriver(
      ride.pickup_lat,
      ride.pickup_lng,
      excludeDriverIds,
    )
    if (!match) {
      this.logger.warn(`No driver found for ride ${ride.id}`)
      return
    }

    await this.rideRepository.update(ride.id, {
      driver_id: match.driver_id,
      status: RideStatus.MATCHED,
    })
    await this.driversService.setDriverStatus(match.driver_id, DriverStatus.BUSY)
    this.logger.log(`Ride ${ride.id} matched to driver ${match.driver_id} (score: ${match.score.toFixed(3)})`)
  }

  async findById(id: string): Promise<RideEntity> {
    const ride = await this.rideRepository.findOne({ where: { id } })
    if (!ride) throw new NotFoundException(`Ride ${id} not found`)
    return ride
  }

  async findByRider(riderId: string): Promise<RideEntity[]> {
    return this.rideRepository.find({
      where: { rider_id: riderId },
      order: { created_at: 'DESC' },
    })
  }

  async list(opts: RideListOptions = {}) {
    const page = opts.page ?? 1
    const limit = opts.limit ?? 20
    const where: FindOptionsWhere<RideEntity> = {}

    if (opts.status) where.status = opts.status
    if (opts.fromDate && opts.toDate) {
      where.created_at = Between(opts.fromDate, opts.toDate)
    }

    const [data, total] = await this.rideRepository.findAndCount({
      where,
      skip: (page - 1) * limit,
      take: limit,
      order: { created_at: 'DESC' },
    })

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async updateStatus(id: string, dto: UpdateRideStatusDto): Promise<RideEntity> {
    const ride = await this.findById(id)

    if (dto.status === RideStatus.COMPLETED) {
      await this.rideRepository.update(id, {
        status: dto.status,
        completed_at: new Date(),
      })
      // Free up the driver
      if (ride.driver_id) {
        await this.driversService.setDriverStatus(ride.driver_id, DriverStatus.ONLINE)
      }
    } else if (dto.status === RideStatus.CANCELLED) {
      await this.rideRepository.update(id, { status: dto.status })
      if (ride.driver_id) {
        await this.driversService.setDriverStatus(ride.driver_id, DriverStatus.ONLINE)
      }
    } else {
      await this.rideRepository.update(id, {
        status: dto.status,
        ...(dto.driver_id ? { driver_id: dto.driver_id } : {}),
      })
    }

    return this.findById(id)
  }

  async cancelRide(id: string, reason?: string): Promise<RideEntity> {
    const ride = await this.findById(id)
    if (ride.status === RideStatus.COMPLETED) {
      throw new Error('Cannot cancel completed ride')
    }
    await this.rideRepository.update(id, {
      status: RideStatus.CANCELLED,
      cancellation_reason: reason,
    })
    if (ride.driver_id) {
      await this.driversService.setDriverStatus(ride.driver_id, DriverStatus.ONLINE)
    }
    this.logger.log(`Ride ${id} cancelled: ${reason ?? 'no reason'}`)
    return this.findById(id)
  }

  async triggerSos(id: string, lat?: number, lng?: number): Promise<RideEntity> {
    const ride = await this.findById(id)
    await this.rideRepository.update(id, {
      sos_triggered: true,
      sos_at: new Date(),
    })
    this.logger.warn(`SOS triggered for ride ${id} at ${lat},${lng}`)
    // In production: notify emergency contacts, admin, possibly police
    return this.findById(id)
  }

  async findActiveByDriver(driverId: string): Promise<RideEntity | null> {
    return this.rideRepository.findOne({
      where: [
        { driver_id: driverId, status: RideStatus.MATCHED },
        { driver_id: driverId, status: RideStatus.PICKUP },
        { driver_id: driverId, status: RideStatus.IN_PROGRESS },
      ],
      order: { created_at: 'DESC' },
    })
  }

  async findActiveByRider(riderId: string): Promise<RideEntity | null> {
    return this.rideRepository.findOne({
      where: [
        { rider_id: riderId, status: RideStatus.REQUESTED },
        { rider_id: riderId, status: RideStatus.MATCHED },
        { rider_id: riderId, status: RideStatus.PICKUP },
        { rider_id: riderId, status: RideStatus.IN_PROGRESS },
      ],
      order: { created_at: 'DESC' },
    })
  }

  async getStats(driverId: string, days = 7) {
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000)
    const rides = await this.rideRepository
      .createQueryBuilder('ride')
      .where('ride.driver_id = :driverId', { driverId })
      .andWhere('ride.status = :status', { status: RideStatus.COMPLETED })
      .andWhere('ride.completed_at >= :since', { since })
      .getMany()

    const totalEarnings = rides.reduce((sum: number, r: RideEntity) => sum + Number(r.fare ?? 0), 0)
    const totalRides = rides.length
    const totalDistance = rides.reduce((sum: number, r: RideEntity) => sum + Number(r.distance_km ?? 0), 0)

    return {
      driverId,
      days,
      totalRides,
      totalEarnings,
      totalDistance: Math.round(totalDistance * 100) / 100,
      avgFarePerRide: totalRides > 0 ? Math.round(totalEarnings / totalRides) : 0,
    }
  }
}
