import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { AuthModule } from './auth/auth.module'
import { UserEntity } from './auth/entities/user.entity'
import { RefreshTokenEntity } from './auth/entities/refresh-token.entity'
import { OtpEntity } from './auth/entities/otp.entity'
import { DeviceEntity } from './auth/entities/device.entity'
import { LoginAttemptEntity } from './auth/entities/login-attempt.entity'
import { HealthController } from './health.controller'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
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
                host: config.get('DB_HOST', 'localhost'),
                port: config.get<number>('DB_PORT', 5432),
                username: config.get('DB_USER', 'crab'),
                password: config.get('DB_PASSWORD', 'crab_secret'),
                database: config.get('DB_NAME', 'crab_db'),
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
})
export class AppModule {}
