import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { RatingsController } from './ratings.controller'
import { RatingsService } from './ratings.service'
import { RatingEntity } from './entities/rating.entity'
import { RatingAggregateEntity } from './entities/rating-aggregate.entity'

@Module({
  imports: [TypeOrmModule.forFeature([RatingEntity, RatingAggregateEntity])],
  controllers: [RatingsController],
  providers: [RatingsService],
  exports: [RatingsService],
})
export class RatingsModule {}
