import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { ProfilesModule } from './profiles/profiles.module'
import { AddressesModule } from './addresses/addresses.module'
import { VerificationModule } from './verification/verification.module'
import { HealthController } from './health.controller'
import { ProfileEntity } from './profiles/entities/profile.entity'
import { AddressEntity } from './addresses/entities/address.entity'
import { DriverProfileEntity } from './verification/entities/driver-profile.entity'
import { MerchantProfileEntity } from './verification/entities/merchant-profile.entity'
import { VerificationDocEntity } from './verification/entities/verification-doc.entity'

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
})
export class AppModule {}
