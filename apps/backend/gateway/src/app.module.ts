import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { HttpModule } from '@nestjs/axios'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler'
import { APP_GUARD } from '@nestjs/core'
import { Redis } from 'ioredis'
import { ObservabilityModule, ResilienceModule } from '@crab/backend-shared'
import configuration from './config/configuration'
import { getRequiredJwtSecret } from './config/security'
import { AuthModule } from './auth/auth.module'
import { ProxyModule } from './proxy/proxy.module'
import { RideGateway } from './gateways/ride.gateway'
import { FoodGateway } from './gateways/food.gateway'
import { ChatGateway } from './gateways/chat.gateway'
import { NotificationGateway } from './gateways/notification.gateway'
import { HealthController } from './health/health.controller'
import { throttlerConfig } from './common/throttler/throttler.config'

const REDIS_CLIENT = 'GATEWAY_REDIS_CLIENT'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    ObservabilityModule,
    ResilienceModule.forRoot({
      redis: { inject: REDIS_CLIENT },
    }),
    ThrottlerModule.forRoot(throttlerConfig),
    HttpModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        timeout: config.get<number>('HTTP_TIMEOUT', 10000),
        maxRedirects: 3,
      }),
    }),
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: getRequiredJwtSecret(config),
        signOptions: { expiresIn: '15m' },
      }),
    }),
    AuthModule,
    ProxyModule,
  ],
  controllers: [HealthController],
  providers: [
    {
      provide: REDIS_CLIENT,
      useFactory: () => new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379'),
    },
    RideGateway,
    FoodGateway,
    ChatGateway,
    NotificationGateway,
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
  exports: [REDIS_CLIENT],
})
export class AppModule {}
