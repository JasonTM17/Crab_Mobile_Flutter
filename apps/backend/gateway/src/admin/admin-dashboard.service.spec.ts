import { Test, TestingModule } from '@nestjs/testing'
import { HttpService } from '@nestjs/axios'
import { ConfigService } from '@nestjs/config'
import { of } from 'rxjs'
import { AdminDashboardService } from './admin-dashboard.service'

describe('AdminDashboardService', () => {
  let service: AdminDashboardService

  const http = {
    get: jest.fn(),
  }
  const config = {
    get: jest.fn((key: string, fallback?: string) => {
      const values: Record<string, string> = {
        AUTH_SERVICE_URL: 'http://auth-service:3001',
        USER_SERVICE_URL: 'http://user-service:3002',
        RIDE_SERVICE_URL: 'http://ride-service:3003',
        FOOD_SERVICE_URL: 'http://food-service:3004',
        PAYMENT_SERVICE_URL: 'http://payment-service:3005',
      }
      return values[key] ?? fallback
    }),
  }

  beforeEach(async () => {
    jest.clearAllMocks()
    http.get.mockImplementation((url: string) => {
      if (url.includes('/profiles')) return of({ data: { data: [], total: 12 } })
      if (url.includes('/rides') && url.includes('status=IN_PROGRESS')) {
        return of({ data: { data: [], total: 3 } })
      }
      if (url.includes('/orders')) return of({ data: { data: [], total: 9 } })
      if (url.includes('/transactions')) {
        return of({ data: { data: [{ amount: 125000 }, { amount: -15000 }, { amount: 90000 }] } })
      }
      return of({ data: { message: 'missing' } })
    })

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AdminDashboardService,
        { provide: HttpService, useValue: http },
        { provide: ConfigService, useValue: config },
      ],
    }).compile()

    service = module.get(AdminDashboardService)
  })

  it('returns dashboard summary built from existing service endpoints', async () => {
    const result = await service.getSummary()

    expect(result.totalUsers).toBe(12)
    expect(result.activeRides).toBe(3)
    expect(result.ordersToday).toBe(9)
    expect(result.revenueMonth).toBe(215000)
  })
})
