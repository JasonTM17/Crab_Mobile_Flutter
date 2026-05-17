import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { RideEntity } from './entities/ride.entity'
import { RidesController } from './rides.controller'
import { RidesService } from './rides.service'
import { FareModule } from '../fare/fare.module'
import { MatchingModule } from '../matching/matching.module'
import { DriversModule } from '../drivers/drivers.module'

@Module({
  imports: [
    TypeOrmModule.forFeature([RideEntity]),
    FareModule,
    MatchingModule,
    DriversModule,
  ],
  controllers: [RidesController],
  providers: [RidesService],
  exports: [RidesService],
})
export class RidesModule {}
