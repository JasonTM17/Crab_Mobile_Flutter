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

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    // PostgreSQL — ride records
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get('DB_USER', 'crab'),
        password: config.get('DB_PASSWORD', 'crab_password'),
        database: config.get('DB_NAME', 'crab_rides'),
        entities: [RideEntity],
        synchronize: config.get('NODE_ENV') !== 'production',
        logging: config.get('NODE_ENV') === 'development',
      }),
    }),

    // MongoDB — driver locations (geospatial)
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGO_URI', 'mongodb://localhost:27017/crab_rides'),
      }),
    }),

    RidesModule,
    DriversModule,
    MatchingModule,
    FareModule,
    TrackingModule,
  ],
})
export class AppModule {}
