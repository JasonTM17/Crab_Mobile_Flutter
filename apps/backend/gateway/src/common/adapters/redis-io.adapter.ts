import { IoAdapter } from '@nestjs/platform-socket.io'
import { ServerOptions } from 'socket.io'
import { createAdapter } from '@socket.io/redis-adapter'
import { INestApplicationContext, Logger } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import Redis from 'ioredis'

export class RedisIoAdapter extends IoAdapter {
  private readonly logger = new Logger(RedisIoAdapter.name)
  private adapterConstructor!: ReturnType<typeof createAdapter>

  constructor(private readonly app: INestApplicationContext) {
    super(app)
  }

  async connectToRedis(): Promise<void> {
    const config = this.app.get(ConfigService)
    const redisUrl = config.get<string>('REDIS_URL', 'redis://localhost:6379')

    const pubClient = new Redis(redisUrl, {
      maxRetriesPerRequest: null,
      enableReadyCheck: false,
    })
    const subClient = pubClient.duplicate()

    pubClient.on('connect', () => this.logger.log('Socket.IO Redis pub connected'))
    subClient.on('connect', () => this.logger.log('Socket.IO Redis sub connected'))
    pubClient.on('error', (err: Error) =>
      this.logger.error('Pub error', err.message),
    )
    subClient.on('error', (err: Error) =>
      this.logger.error('Sub error', err.message),
    )

    this.adapterConstructor = createAdapter(pubClient, subClient)
  }

  override createIOServer(port: number, options?: ServerOptions): unknown {
    const server = super.createIOServer(port, {
      ...options,
      cors: { origin: '*', credentials: true },
      pingInterval: 25000,
      pingTimeout: 60000,
      transports: ['websocket'],
    })
    if (this.adapterConstructor) {
      server.adapter(this.adapterConstructor)
    }
    return server
  }
}
