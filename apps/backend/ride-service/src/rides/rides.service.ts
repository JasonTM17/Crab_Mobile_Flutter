import { Injectable, NotFoundException, Logger } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { RideEntity } from './entities/ride.entity'
import { CreateRideDto } from './dto/create-ride.dto'
import { UpdateRideStatusDto } from './dto/update-ride-status.dto'
import { FareService } from '../fare/fare.service'
import { MatchingService } from '../matching/matching.service'
import { DriversService } from '../drivers/drivers.service'
import { RideStatus } from '@crab/common-types'
import { DriverStatus } from '../drivers/schemas/driver-location.schema'

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
    })

    const saved = await this.rideRepository.save(ride)
    this.logger.log(`Ride created: ${saved.id} for rider ${dto.rider_id}`)

    // Attempt driver matching asynchronously
    this.matchDriver(saved).catch((err) =>
      this.logger.error(`Driver matching failed for ride ${saved.id}: ${err.message}`),
    )

    return saved
  }

  private async matchDriver(ride: RideEntity): Promise<void> {
    const match = await this.matchingService.findBestDriver(ride.pickup_lat, ride.pickup_lng)
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
}
