import { Test, TestingModule } from '@nestjs/testing'
import { getRepositoryToken } from '@nestjs/typeorm'
import { DataSource } from 'typeorm'
import { ConflictException } from '@nestjs/common'
import { RatingsService } from './ratings.service'
import { RatingEntity, RatingTargetType } from './entities/rating.entity'
import { RatingAggregateEntity } from './entities/rating-aggregate.entity'

describe('RatingsService', () => {
  let service: RatingsService

  const mockRatingRepo = {
    findOne: jest.fn(),
    find: jest.fn(),
    update: jest.fn(),
    createQueryBuilder: jest.fn(),
  }
  const mockAggRepo = {
    findOne: jest.fn(),
  }
  const mockDataSource: Partial<DataSource> = {
    transaction: jest.fn(),
  }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RatingsService,
        { provide: getRepositoryToken(RatingEntity), useValue: mockRatingRepo },
        { provide: getRepositoryToken(RatingAggregateEntity), useValue: mockAggRepo },
        { provide: DataSource, useValue: mockDataSource },
      ],
    }).compile()

    service = module.get<RatingsService>(RatingsService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('getAggregate', () => {
    it('returns zero-default payload when no aggregate exists', async () => {
      mockAggRepo.findOne.mockResolvedValueOnce(null)
      const result = await service.getAggregate('drv-1', RatingTargetType.DRIVER)
      expect(result.avgScore).toBe(0)
      expect(result.totalRatings).toBe(0)
      expect(result.distribution).toEqual({ 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 })
    })

    it('returns the existing aggregate when found', async () => {
      mockAggRepo.findOne.mockResolvedValueOnce({
        targetId: 'drv-1',
        targetType: RatingTargetType.DRIVER,
        avgScore: '4.50',
        totalRatings: 10,
        count1: 0,
        count2: 1,
        count3: 1,
        count4: 3,
        count5: 5,
      })
      const result = await service.getAggregate('drv-1', RatingTargetType.DRIVER)
      expect(result.avgScore).toBe(4.5)
      expect(result.totalRatings).toBe(10)
      expect(result.distribution).toEqual({ 1: 0, 2: 1, 3: 1, 4: 3, 5: 5 })
    })
  })

  describe('create', () => {
    it('throws ConflictException when same rater rated same reference', async () => {
      mockRatingRepo.findOne.mockResolvedValueOnce({ id: 'existing' })
      await expect(
        service.create({
          referenceId: 'ride-1',
          raterId: 'u1',
          targetId: 'drv-1',
          targetType: RatingTargetType.DRIVER,
          score: 5,
        } as never),
      ).rejects.toThrow(ConflictException)
    })

    it('computes the correct rolling average when an aggregate already exists', async () => {
      mockRatingRepo.findOne.mockResolvedValueOnce(null)
      const existingAgg = {
        targetId: 'drv-1',
        targetType: RatingTargetType.DRIVER,
        avgScore: 4,
        totalRatings: 2,
        count1: 0,
        count2: 0,
        count3: 0,
        count4: 2,
        count5: 0,
      }
      const tx = jest.fn(async (cb: any) => {
        const manager = {
          create: jest.fn((_, x) => x),
          save: jest.fn(async (x) => x),
          findOne: jest.fn().mockResolvedValue(existingAgg),
        }
        return cb(manager)
      })
      ;(mockDataSource.transaction as jest.Mock) = tx

      await service.create({
        referenceId: 'ride-1',
        raterId: 'u1',
        targetId: 'drv-1',
        targetType: RatingTargetType.DRIVER,
        score: 5,
      } as never)

      // (4*2 + 5) / 3 = 4.33
      expect(existingAgg.avgScore).toBeCloseTo(4.33, 2)
      expect(existingAgg.totalRatings).toBe(3)
      expect(existingAgg.count5).toBe(1)
    })
  })
})
