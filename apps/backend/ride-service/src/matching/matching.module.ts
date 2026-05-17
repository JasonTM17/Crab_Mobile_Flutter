import { Module } from '@nestjs/common'
import { DriversModule } from '../drivers/drivers.module'
import { FareModule } from '../fare/fare.module'
import { MatchingService } from './matching.service'

@Module({
  imports: [DriversModule, FareModule],
  providers: [MatchingService],
  exports: [MatchingService],
})
export class MatchingModule {}
