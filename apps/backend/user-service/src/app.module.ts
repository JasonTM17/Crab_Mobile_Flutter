import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { Redis } from 'ioredis'
import { ObservabilityModule, ResilienceModule } from '@crab/backend-shared'
import { ProfilesModule } from './profiles/profiles.module'
import { AddressesModule } from './addresses/addresses.module'
import { VerificationModule } from './verification/verification.module'
import { HealthController } from './health.controller'
import { ProfileEntity } from './profiles/entities/profile.entity'
import { AddressEntity } from './addresses/entities/address.entity'
import { DriverProfileEntity } from './verification/entities/driver-profile.entity'
import { MerchantProfileEntity } from './verification/entities/merchant-profile.entity'
import { VerificationDocEntity } from './verification/entities/verification-doc.entity'

const REDIS_CLIENT = 'USER_REDIS_CLIENT'

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
          entities: [
            ProfileEntity,
            AddressEntity,
            DriverProfileEntity,
            MerchantProfileEntity,
            VerificationDocEntity,
          ],
          synchronize: config.get('NODE_ENV') !== 'production',
        }
      },
    }),
    ProfilesModule,
    AddressesModule,
    VerificationModule,
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
