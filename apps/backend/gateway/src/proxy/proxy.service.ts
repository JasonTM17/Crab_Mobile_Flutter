import {
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { HttpService } from '@nestjs/axios'
import { firstValueFrom } from 'rxjs'
import { AxiosRequestConfig } from 'axios'
import { CircuitBreaker } from '../common/circuit-breaker/circuit-breaker'

export type ServiceName =
  | 'auth'
  | 'user'
  | 'ride'
  | 'food'
  | 'payment'
  | 'chat'
  | 'notification'
  | 'rating'

@Injectable()
export class ProxyService {
  private readonly logger = new Logger(ProxyService.name)
  private readonly breakers = new Map<ServiceName, CircuitBreaker>()
  private readonly serviceUrls: Record<ServiceName, string>

  constructor(
    private readonly config: ConfigService,
    private readonly http: HttpService,
  ) {
    this.serviceUrls = {
      auth: config.get('AUTH_SERVICE_URL', 'http://localhost:3001'),
      user: config.get('USER_SERVICE_URL', 'http://localhost:3002'),
      ride: config.get('RIDE_SERVICE_URL', 'http://localhost:3003'),
      food: config.get('FOOD_SERVICE_URL', 'http://localhost:3004'),
      payment: config.get('PAYMENT_SERVICE_URL', 'http://localhost:3005'),
      chat: config.get('CHAT_SERVICE_URL', 'http://localhost:3006'),
      notification: config.get(
        'NOTIFICATION_SERVICE_URL',
        'http://localhost:3007',
      ),
      rating: config.get('RATING_SERVICE_URL', 'http://localhost:3008'),
    }

    for (const name of Object.keys(this.serviceUrls) as ServiceName[]) {
      this.breakers.set(name, new CircuitBreaker(name))
    }
  }

  async forward<T = unknown>(
    service: ServiceName,
    method: string,
    path: string,
    data?: unknown,
    headers?: Record<string, string>,
  ): Promise<T> {
    const breaker = this.breakers.get(service)!
    const url = `${this.serviceUrls[service]}/api/v1${path}`

    return breaker.execute(async () => {
      try {
        const config: AxiosRequestConfig = {
          method,
          url,
          data,
          headers: { ...headers, 'X-Forwarded-By': 'crab-gateway' },
          timeout: 10000,
          validateStatus: () => true,
        }
        const response = await firstValueFrom(this.http.request<T>(config))
        if (response.status >= 500) {
          throw new ServiceUnavailableException(`${service} service error`)
        }
        if (response.status >= 400) {
          // Re-throw downstream errors as-is
          throw {
            status: response.status,
            message:
              (response.data as { message?: string })?.message ??
              'Request failed',
            data: response.data,
          }
        }
        return response.data
      } catch (err: unknown) {
        const e = err as { status?: number; message?: string }
        if (e.status) throw err
        this.logger.error(
          `Proxy error to ${service}: ${e.message ?? 'unknown'}`,
        )
        throw new ServiceUnavailableException(
          `${service} service unavailable`,
        )
      }
    })
  }

  getCircuitStatus(): Record<string, string> {
    const status: Record<string, string> = {}
    for (const [name, breaker] of this.breakers.entries()) {
      status[name] = breaker.getState()
    }
    return status
  }
}
