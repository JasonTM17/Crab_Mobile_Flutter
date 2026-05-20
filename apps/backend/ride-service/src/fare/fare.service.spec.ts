import { Test, TestingModule } from '@nestjs/testing'
import { FareService, VehicleType } from './fare.service'

/**
 * Pure-math unit tests for FareService.
 * No external dependencies, no mocks needed.
 */
describe('FareService', () => {
  let service: FareService

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [FareService],
    }).compile()
    service = module.get<FareService>(FareService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('calculateDistance (Haversine)', () => {
    it('returns 0 for identical coordinates', () => {
      const d = service.calculateDistance(10.7769, 106.7009, 10.7769, 106.7009)
      expect(d).toBeCloseTo(0, 5)
    })

    it('computes a reasonable distance between two HCMC points (~5km)', () => {
      // District 1 → Tan Binh approx 5–7 km
      const d = service.calculateDistance(10.7769, 106.7009, 10.8014, 106.6438)
      expect(d).toBeGreaterThan(3)
      expect(d).toBeLessThan(10)
    })

    it('is symmetric (A→B == B→A)', () => {
      const ab = service.calculateDistance(10.0, 106.0, 11.0, 107.0)
      const ba = service.calculateDistance(11.0, 107.0, 10.0, 106.0)
      expect(ab).toBeCloseTo(ba, 6)
    })
  })

  describe('calculateSurge', () => {
    it('returns 1.0 when ratio < 0.5', () => {
      expect(service.calculateSurge(2, 10)).toBe(1.0)
    })

    it('returns 1.2 when ratio is between 0.5 and 1.0', () => {
      expect(service.calculateSurge(7, 10)).toBe(1.2)
    })

    it('returns 1.5 when ratio is between 1.0 and 2.0', () => {
      expect(service.calculateSurge(15, 10)).toBe(1.5)
    })

    it('returns 2.0 when ratio is >= 2.0', () => {
      expect(service.calculateSurge(25, 10)).toBe(2.0)
    })

    it('returns 2.0 when no drivers are online (avoid divide-by-zero)', () => {
      expect(service.calculateSurge(5, 0)).toBe(2.0)
    })
  })

  describe('estimate', () => {
    it('returns a fare with all required fields', () => {
      const e = service.estimate(10.7769, 106.7009, 10.8014, 106.6438)
      expect(e).toHaveProperty('total_fare')
      expect(e).toHaveProperty('base_fare')
      expect(e).toHaveProperty('distance_fare')
      expect(e).toHaveProperty('time_fare')
      expect(e).toHaveProperty('surge_multiplier')
      expect(e).toHaveProperty('distance_km')
      expect(e).toHaveProperty('duration_min')
      expect(e.surge_multiplier).toBe(1.0)
    })

    it('respects min fare for very short trips', () => {
      // Almost-zero distance ⇒ subtotal is below minFare ⇒ total clamps to minFare
      const e = service.estimate(10.7769, 106.7009, 10.7770, 106.7010, 1.0, VehicleType.BIKE)
      expect(e.total_fare).toBeGreaterThanOrEqual(12000) // BIKE minFare
    })

    it('applies surge multiplier to subtotal', () => {
      const noSurge = service.estimate(10.0, 106.0, 10.5, 106.5, 1.0, VehicleType.CAR_4)
      const surged = service.estimate(10.0, 106.0, 10.5, 106.5, 2.0, VehicleType.CAR_4)
      expect(surged.total_fare).toBeGreaterThan(noSurge.total_fare)
      expect(surged.surge_multiplier).toBe(2.0)
    })

    it('produces higher fares for premium vs bike on the same trip', () => {
      const bike = service.estimate(10.0, 106.0, 10.5, 106.5, 1.0, VehicleType.BIKE)
      const premium = service.estimate(10.0, 106.0, 10.5, 106.5, 1.0, VehicleType.PREMIUM)
      expect(premium.total_fare).toBeGreaterThan(bike.total_fare)
    })
  })

  describe('estimateAllTypes', () => {
    it('returns an estimate for every VehicleType', () => {
      const all = service.estimateAllTypes(10.0, 106.0, 10.5, 106.5)
      expect(all).toHaveLength(Object.values(VehicleType).length)
      const types = all.map((e) => e.vehicleType).sort()
      expect(types).toEqual([...Object.values(VehicleType)].sort())
    })
  })
})
