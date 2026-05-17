import { Injectable } from '@nestjs/common'
import { HttpService } from '@nestjs/axios'
import { ConfigService } from '@nestjs/config'
import { firstValueFrom } from 'rxjs'
import { AxiosRequestConfig } from 'axios'

@Injectable()
export class ProxyService {
  private readonly authServiceUrl: string
  private readonly userServiceUrl: string

  constructor(
    private readonly http: HttpService,
    private readonly config: ConfigService,
  ) {
    this.authServiceUrl = this.config.get<string>(
      'AUTH_SERVICE_URL',
      'http://localhost:3001',
    )
    this.userServiceUrl = this.config.get<string>(
      'USER_SERVICE_URL',
      'http://localhost:3002',
    )
  }

  async forwardToAuth(
    path: string,
    method: string,
    data?: unknown,
    headers?: Record<string, string>,
  ) {
    return this.forward(`${this.authServiceUrl}${path}`, method, data, headers)
  }

  async forwardToUser(
    path: string,
    method: string,
    data?: unknown,
    headers?: Record<string, string>,
  ) {
    return this.forward(`${this.userServiceUrl}${path}`, method, data, headers)
  }

  private async forward(
    url: string,
    method: string,
    data?: unknown,
    headers?: Record<string, string>,
  ) {
    const config: AxiosRequestConfig = {
      url,
      method,
      data,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    }
    const response = await firstValueFrom(this.http.request(config))
    return response.data
  }
}
