import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { HttpModule } from '@nestjs/axios'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler'
import { APP_GUARD } from '@nestjs/core'
import configuration from './config/configuration'
import { AuthModule } from './auth/auth.module'
import { ProxyModule } from './proxy/proxy.module'
import { RideGateway } from './gateways/ride.gateway'
import { FoodGateway } from './gateways/food.gateway'
import { ChatGateway } from './gateways/chat.gateway'
import { NotificationGateway } from './gateways/notification.gateway'
import { HealthController } from './health/health.controller'
import { throttlerConfig } from './common/throttler/throttler.config'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
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
        secret: config.get<string>('jwtSecret', 'change-me-in-production'),
        signOptions: { expiresIn: '15m' },
      }),
    }),
    AuthModule,
    ProxyModule,
  ],
  controllers: [HealthController],
  providers: [
    RideGateway,
    FoodGateway,
    ChatGateway,
    NotificationGateway,
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
