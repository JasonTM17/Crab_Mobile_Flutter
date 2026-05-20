import { Test, TestingModule } from '@nestjs/testing'
import { getRepositoryToken } from '@nestjs/typeorm'
import { DataSource } from 'typeorm'
import {
  BadRequestException,
  NotFoundException,
} from '@nestjs/common'
import { PromoService } from './promo.service'
import {
  PromoEntity,
  PromoUsageEntity,
  PromoType,
  PromoApplicableTo,
} from './entities/promo.entity'

describe('PromoService', () => {
  let service: PromoService

  const mockPromoRepo = {
    findOne: jest.fn(),
    find: jest.fn(),
    create: jest.fn((x) => x),
    save: jest.fn(async (x) => x),
    update: jest.fn(),
  }
  const mockUsageRepo = { count: jest.fn() }
  const mockDataSource: Partial<DataSource> = { transaction: jest.fn() }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PromoService,
        { provide: getRepositoryToken(PromoEntity), useValue: mockPromoRepo },
        {
          provide: getRepositoryToken(PromoUsageEntity),
          useValue: mockUsageRepo,
        },
        { provide: DataSource, useValue: mockDataSource },
      ],
    }).compile()
    service = module.get<PromoService>(PromoService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('findByCode', () => {
    it('throws NotFoundException when no promo matches the code', async () => {
      mockPromoRepo.findOne.mockResolvedValueOnce(null)
      await expect(service.findByCode('GHOST')).rejects.toThrow(NotFoundException)
    })
  })

  describe('validate', () => {
    const basePromo = {
      id: 'p-1',
      code: 'WELCOME',
      type: PromoType.PERCENTAGE,
      value: 20,
      maxDiscount: 50000,
      minOrderValue: 0,
      isActive: true,
      validFrom: new Date(Date.now() - 60_000),
      validUntil: new Date(Date.now() + 60_000),
      applicableTo: PromoApplicableTo.ALL,
      usageLimitPerUser: 1,
      totalUsageLimit: 0,
      totalUsed: 0,
    }

    it('rejects an inactive promo', async () => {
      mockPromoRepo.findOne.mockResolvedValueOnce({ ...basePromo, isActive: false })
      await expect(
        service.validate({ code: 'WELCOME', userId: 'u1', orderValue: 100000 } as never),
      ).rejects.toThrow(BadRequestException)
    })

    it('rejects when user already exhausted their per-user limit', async () => {
      mockPromoRepo.findOne.mockResolvedValueOnce(basePromo)
      mockUsageRepo.count.mockResolvedValueOnce(1) // already used once, limit 1
      await expect(
        service.validate({ code: 'WELCOME', userId: 'u1', orderValue: 100000 } as never),
      ).rejects.toThrow('Promo already used')
    })

    it('caps percentage discount at maxDiscount and computes finalAmount', async () => {
      mockPromoRepo.findOne.mockResolvedValueOnce(basePromo)
      mockUsageRepo.count.mockResolvedValueOnce(0)
      const result = await service.validate({
        code: 'WELCOME',
        userId: 'u1',
        orderValue: 1_000_000, // 20% = 200000, capped at maxDiscount=50000
      } as never)
      expect(result.discountAmount).toBe(50000)
      expect(result.finalAmount).toBe(950_000)
    })
  })
})
