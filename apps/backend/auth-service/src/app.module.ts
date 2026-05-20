import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { Redis } from 'ioredis'
import { ObservabilityModule, ResilienceModule } from '@crab/backend-shared'
import { AuthModule } from './auth/auth.module'
import { UserEntity } from './auth/entities/user.entity'
import { RefreshTokenEntity } from './auth/entities/refresh-token.entity'
import { OtpEntity } from './auth/entities/otp.entity'
import { DeviceEntity } from './auth/entities/device.entity'
import { LoginAttemptEntity } from './auth/entities/login-attempt.entity'
import { HealthController } from './health.controller'

const REDIS_CLIENT = 'AUTH_REDIS_CLIENT'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ObservabilityModule,
    ResilienceModule.forRoot({ redis: { inject: REDIS_CLIENT } }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const url = config.get<string>('DATABASE_URL')
        return {
          type: 'postgres' as const,
          ...(url
            ? { url }
            : {
                host: config.get<string>('DB_HOST', 'localhost'),
                port: config.get<number>('DB_PORT', 5432),
                username: config.get<string>('DB_USER', 'crab'),
                password: config.get<string>('DB_PASSWORD', 'crab_secret'),
                database: config.get<string>('DB_NAME', 'crab_db'),
              }),
          entities: [UserEntity, RefreshTokenEntity, OtpEntity, DeviceEntity, LoginAttemptEntity],
          synchronize: config.get('NODE_ENV') !== 'production',
          logging: config.get('NODE_ENV') === 'development',
        }
      },
    }),
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get('JWT_SECRET', 'change-me-in-production'),
        signOptions: { expiresIn: '15m' },
      }),
    }),
    AuthModule,
  ],
  controllers: [HealthController],
  providers: [
    {
      provide: REDIS_CLIENT,
      useFactory: () => new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379'),
    },
  ],
  exports: [REDIS_CLIENT],
})
export class AppModule {}
