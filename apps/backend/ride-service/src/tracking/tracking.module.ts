import { Module } from '@nestjs/common'
import { MongooseModule } from '@nestjs/mongoose'
import { DriverLocation, DriverLocationSchema } from '../drivers/schemas/driver-location.schema'
import { TrackingService } from './tracking.service'

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: DriverLocation.name, schema: DriverLocationSchema },
    ]),
  ],
  providers: [TrackingService],
  exports: [TrackingService],
})
export class TrackingModule {}
