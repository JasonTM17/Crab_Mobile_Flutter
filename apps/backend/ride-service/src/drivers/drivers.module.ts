import { Module } from '@nestjs/common'
import { MongooseModule } from '@nestjs/mongoose'
import { DriverLocation, DriverLocationSchema } from './schemas/driver-location.schema'
import { DriversController } from './drivers.controller'
import { DriversService } from './drivers.service'

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: DriverLocation.name, schema: DriverLocationSchema },
    ]),
  ],
  controllers: [DriversController],
  providers: [DriversService],
  exports: [DriversService, MongooseModule],
})
export class DriversModule {}
