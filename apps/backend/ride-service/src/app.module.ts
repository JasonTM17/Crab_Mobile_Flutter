import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { MongooseModule } from '@nestjs/mongoose'
import { RidesModule } from './rides/rides.module'
import { DriversModule } from './drivers/drivers.module'
import { MatchingModule } from './matching/matching.module'
import { FareModule } from './fare/fare.module'
import { TrackingModule } from './tracking/tracking.module'
import { RideEntity } from './rides/entities/ride.entity'
import { HealthController } from './health.controller'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    // PostgreSQL — ride records
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
          entities: [RideEntity],
          synchronize: config.get('NODE_ENV') !== 'production',
          logging: config.get('NODE_ENV') === 'development',
        }
      },
    }),

    // MongoDB — driver locations (geospatial)
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri:
          config.get<string>('MONGODB_URI') ||
          config.get<string>('MONGO_URI') ||
          'mongodb://localhost:27017/crab_rides',
      }),
    }),

    RidesModule,
    DriversModule,
    MatchingModule,
    FareModule,
    TrackingModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
