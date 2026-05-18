import { Module } from '@nestjs/common'
import { ConfigModule } from '@nestjs/config'
import { MongooseModule } from '@nestjs/mongoose'
import { DriverLocation, DriverLocationSchema } from '../drivers/schemas/driver-location.schema'
import { TrackingService } from './tracking.service'

@Module({
  imports: [
    ConfigModule,
    MongooseModule.forFeature([
      { name: DriverLocation.name, schema: DriverLocationSchema },
    ]),
  ],
  providers: [TrackingService],
  exports: [TrackingService],
})
export class TrackingModule {}
