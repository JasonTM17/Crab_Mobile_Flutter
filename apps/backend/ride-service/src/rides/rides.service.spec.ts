import { Test, TestingModule } from '@nestjs/testing'
import { getRepositoryToken } from '@nestjs/typeorm'
import { NotFoundException } from '@nestjs/common'
import { RideStatus } from '@crab/common-types'
import { RidesService } from './rides.service'
import { RideEntity } from './entities/ride.entity'
import { FareService } from '../fare/fare.service'
import { MatchingService } from '../matching/matching.service'
import { DriversService } from '../drivers/drivers.service'
import { DriverStatus } from '../drivers/schemas/driver-location.schema'

describe('RidesService', () => {
  let service: RidesService

  const mockRideRepo = {
    create: jest.fn((dto) => dto),
    save: jest.fn(async (x) => ({ id: 'ride-1', ...x })),
    findOne: jest.fn(),
    find: jest.fn(),
    update: jest.fn(),
    count: jest.fn().mockResolvedValue(0),
  }

  const mockFare = {
    calculateSurge: jest.fn().mockReturnValue(1.0),
    estimate: jest
      .fn()
      .mockReturnValue({ total_fare: 50000, distance_km: 5, duration_min: 12 }),
  }

  const mockMatching = {
    findBestDriver: jest.fn().mockResolvedValue(null),
  }

  const mockDrivers = {
    countOnlineDrivers: jest.fn().mockResolvedValue(10),
    setDriverStatus: jest.fn().mockResolvedValue(undefined),
  }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RidesService,
        { provide: getRepositoryToken(RideEntity), useValue: mockRideRepo },
        { provide: FareService, useValue: mockFare },
        { provide: MatchingService, useValue: mockMatching },
        { provide: DriversService, useValue: mockDrivers },
      ],
    }).compile()

    service = module.get<RidesService>(RidesService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('create', () => {
    it('persists a ride using the fare estimate and current surge', async () => {
      const dto = {
        rider_id: 'rider-1',
        pickup_lat: 10.7,
        pickup_lng: 106.6,
        pickup_address: 'A',
        dropoff_lat: 10.8,
        dropoff_lng: 106.7,
        dropoff_address: 'B',
      }
      const saved = await service.create(dto as never)
      expect(mockFare.estimate).toHaveBeenCalled()
      expect(mockRideRepo.save).toHaveBeenCalled()
      expect(saved.id).toBe('ride-1')
      expect((saved as RideEntity).fare).toBe(50000)
      expect((saved as RideEntity).status).toBe(RideStatus.REQUESTED)
    })
  })

  describe('findById', () => {
    it('throws NotFoundException when the ride does not exist', async () => {
      mockRideRepo.findOne.mockResolvedValueOnce(null)
      await expect(service.findById('missing')).rejects.toThrow(NotFoundException)
    })
  })

  describe('cancelRide', () => {
    it('refuses to cancel a completed ride', async () => {
      mockRideRepo.findOne.mockResolvedValueOnce({
        id: 'r1',
        status: RideStatus.COMPLETED,
      })
      await expect(service.cancelRide('r1')).rejects.toThrow(
        'Cannot cancel completed ride',
      )
    })

    it('marks the ride cancelled and frees the driver', async () => {
      mockRideRepo.findOne
        .mockResolvedValueOnce({
          id: 'r1',
          status: RideStatus.MATCHED,
          driver_id: 'drv-1',
        })
        .mockResolvedValueOnce({
          id: 'r1',
          status: RideStatus.CANCELLED,
          driver_id: 'drv-1',
        })

      await service.cancelRide('r1', 'rider asked')
      expect(mockRideRepo.update).toHaveBeenCalledWith('r1', {
        status: RideStatus.CANCELLED,
        cancellation_reason: 'rider asked',
      })
      expect(mockDrivers.setDriverStatus).toHaveBeenCalledWith(
        'drv-1',
        DriverStatus.ONLINE,
      )
    })
  })
})
