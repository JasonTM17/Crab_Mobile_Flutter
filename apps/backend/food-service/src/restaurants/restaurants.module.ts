import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { RestaurantsController } from './restaurants.controller'
import { RestaurantsService } from './restaurants.service'
import { RestaurantEntity } from './entities/restaurant.entity'

@Module({
  imports: [TypeOrmModule.forFeature([RestaurantEntity])],
  controllers: [RestaurantsController],
  providers: [RestaurantsService],
  exports: [RestaurantsService],
})
export class RestaurantsModule {}
