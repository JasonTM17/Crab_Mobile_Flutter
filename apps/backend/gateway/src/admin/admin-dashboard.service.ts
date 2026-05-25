import { HttpService } from '@nestjs/axios'
import { Injectable } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { firstValueFrom } from 'rxjs'

interface CountResponse<T = unknown> {
  data?: T[]
  total?: number
  page?: number
  limit?: number
  totalPages?: number
}

interface RideSummary {
  created_at?: string
  createdAt?: string
  vehicle_type?: string
  vehicleType?: string
}

interface OrderSummary {
  restaurantId?: string
  createdAt?: string
  created_at?: string
}

interface TransactionSummary {
  amount?: number | string
}

interface RestaurantSummary {
  id: string
  name: string
  totalOrders?: number
}

export interface AdminDashboardSummary {
  totalUsers?: number
  activeRides?: number
  ordersToday?: number
  revenueMonth?: number
  ridesByHour?: { hour: string; count: number }[]
  topRestaurants?: { name: string; orders: number }[]
  vehicleMix?: { type: string; value: number }[]
}

@Injectable()
export class AdminDashboardService {
  constructor(
    private readonly http: HttpService,
    private readonly config: ConfigService,
  ) {}

  async getSummary(): Promise<AdminDashboardSummary> {
    const [users, rides, orders, transactions, restaurants] = await Promise.all([
      this.tryGet<CountResponse>(this.profilesQuery()),
      this.tryGet<CountResponse<RideSummary>>(this.ridesQuery()),
      this.tryGet<CountResponse<OrderSummary>>(this.ordersQuery()),
      this.tryGet<CountResponse<TransactionSummary>>(this.transactionsQuery()),
      this.tryGet<CountResponse<RestaurantSummary>>(this.restaurantsQuery()),
    ])

    const rideItems = rides?.data ?? []
    const orderItems = orders?.data ?? []
    const restaurantItems = restaurants?.data ?? []
    const transactionItems = transactions?.data ?? []

    return {
      totalUsers: users?.total ?? 0,
      activeRides: rides?.total ?? 0,
      ordersToday: orders?.total ?? 0,
      revenueMonth: transactionItems
        .map((tx) => Number(tx.amount ?? 0))
        .filter((amount) => amount > 0)
        .reduce((sum, amount) => sum + amount, 0),
      ridesByHour: this.buildRidesByHour(rideItems),
      topRestaurants: this.buildTopRestaurants(orderItems, restaurantItems),
      vehicleMix: this.buildVehicleMix(rideItems),
    }
  }

  private async tryGet<T>(url: string): Promise<T | null> {
    try {
      const { data } = await firstValueFrom(this.http.get<T>(url))
      return data ?? null
    } catch {
      return null
    }
  }

  private buildRidesByHour(rides: RideSummary[]) {
    const counts = new Map<string, number>()
    for (const ride of rides) {
      const raw = ride.created_at ?? ride.createdAt
      if (!raw) continue
      const date = new Date(raw)
      const hour = `${date.getHours().toString().padStart(2, '0')}:00`
      counts.set(hour, (counts.get(hour) ?? 0) + 1)
    }

    return [...counts.entries()]
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([hour, count]) => ({ hour, count }))
  }

  private buildTopRestaurants(
    orders: OrderSummary[],
    restaurants: RestaurantSummary[],
  ) {
    const names = new Map(restaurants.map((restaurant) => [restaurant.id, restaurant.name]))
    const counts = new Map<string, number>()

    for (const order of orders) {
      if (!order.restaurantId) continue
      counts.set(order.restaurantId, (counts.get(order.restaurantId) ?? 0) + 1)
    }

    return [...counts.entries()]
      .sort(([, a], [, b]) => b - a)
      .slice(0, 5)
      .map(([restaurantId, orders]) => ({
        name: names.get(restaurantId) ?? restaurantId,
        orders,
      }))
  }

  private buildVehicleMix(rides: RideSummary[]) {
    const counts = new Map<string, number>()
    for (const ride of rides) {
      const type = ride.vehicle_type ?? ride.vehicleType ?? 'UNKNOWN'
      counts.set(type, (counts.get(type) ?? 0) + 1)
    }

    return [...counts.entries()].map(([type, value]) => ({ type, value }))
  }

  private monthRange() {
    const now = new Date()
    const from = new Date(now.getFullYear(), now.getMonth(), 1)
    const to = new Date(now.getFullYear(), now.getMonth() + 1, 1)
    return { from, to }
  }

  private todayRange() {
    const now = new Date()
    const from = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const to = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)
    return { from, to }
  }

  private encodeDate(date: Date) {
    return encodeURIComponent(date.toISOString())
  }

  private profilesQuery() {
    return `${this.userService()}/api/v1/profiles?limit=100`
  }

  private ridesQuery() {
    return `${this.rideService()}/api/v1/rides?limit=100&status=IN_PROGRESS`
  }

  private ordersQuery() {
    const { from, to } = this.todayRange()
    return `${this.foodService()}/api/v1/orders?limit=100&fromDate=${this.encodeDate(from)}&toDate=${this.encodeDate(to)}`
  }

  private transactionsQuery() {
    const { from, to } = this.monthRange()
    return `${this.paymentService()}/api/v1/transactions?limit=100&status=COMPLETED&fromDate=${this.encodeDate(from)}&toDate=${this.encodeDate(to)}`
  }

  private restaurantsQuery() {
    return `${this.foodService()}/api/v1/restaurants/search?limit=20`
  }

  private userService() {
    return this.config.get('USER_SERVICE_URL', 'http://user-service:3002')
  }

  private rideService() {
    return this.config.get('RIDE_SERVICE_URL', 'http://ride-service:3003')
  }

  private foodService() {
    return this.config.get('FOOD_SERVICE_URL', 'http://food-service:3004')
  }

  private paymentService() {
    return this.config.get('PAYMENT_SERVICE_URL', 'http://payment-service:3005')
  }
}
