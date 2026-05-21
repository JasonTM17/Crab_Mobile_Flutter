import { BadRequestException, Body, Controller, Post } from '@nestjs/common'
import { DriversService } from './drivers.service'
import { DriverStatus } from './schemas/driver-location.schema'

@Controller('drivers')
export class DriversController {
  constructor(private readonly driversService: DriversService) {}

  @Post('online')
  async goOnline(@Body('driverId') driverId: string) {
    this.requireDriverId(driverId)
    await this.driversService.setDriverStatus(driverId, DriverStatus.ONLINE)
    return { success: true, status: DriverStatus.ONLINE }
  }

  @Post('offline')
  async goOffline(@Body('driverId') driverId: string) {
    this.requireDriverId(driverId)
    await this.driversService.setDriverStatus(driverId, DriverStatus.OFFLINE)
    return { success: true, status: DriverStatus.OFFLINE }
  }

  @Post('location')
  async updateLocation(
    @Body('driverId') driverId: string,
    @Body('latitude') latitude: number,
    @Body('longitude') longitude: number,
  ) {
    this.requireDriverId(driverId)
    if (!Number.isFinite(Number(latitude)) || !Number.isFinite(Number(longitude))) {
      throw new BadRequestException('latitude and longitude are required')
    }
    await this.driversService.updateLocation(
      driverId,
      Number(latitude),
      Number(longitude),
      DriverStatus.ONLINE,
    )
    return { success: true }
  }

  private requireDriverId(driverId?: string) {
    if (!driverId) {
      throw new BadRequestException('driverId is required')
    }
  }
}
