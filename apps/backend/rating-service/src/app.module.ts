import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { RatingsModule } from './ratings/ratings.module'
import { HealthController } from './health.controller'
import { RatingEntity } from './ratings/entities/rating.entity'
import { RatingAggregateEntity } from './ratings/entities/rating-aggregate.entity'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get('DB_USER', 'crab'),
        password: config.get('DB_PASSWORD', 'crab_secret'),
        database: config.get('DB_NAME', 'crab_db'),
        entities: [RatingEntity, RatingAggregateEntity],
        synchronize: config.get('NODE_ENV') !== 'production',
      }),
    }),
    RatingsModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
