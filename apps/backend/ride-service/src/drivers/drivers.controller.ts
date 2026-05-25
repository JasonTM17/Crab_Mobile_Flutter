import { BadRequestException, Body, Controller, Headers, Post } from '@nestjs/common'
import { DriversService } from './drivers.service'
import { DriverStatus } from './schemas/driver-location.schema'

@Controller('drivers')
export class DriversController {
  constructor(private readonly driversService: DriversService) {}

  @Post('online')
  async goOnline(
    @Headers('x-user-id') authenticatedDriverId: string | undefined,
    @Body() body: { driverId?: string },
  ) {
    this.requireDriverAccess(authenticatedDriverId, body.driverId)
    const driverId = authenticatedDriverId!
    await this.driversService.setDriverStatus(driverId, DriverStatus.ONLINE)
    return { success: true, status: DriverStatus.ONLINE }
  }

  @Post('offline')
  async goOffline(
    @Headers('x-user-id') authenticatedDriverId: string | undefined,
    @Body() body: { driverId?: string },
  ) {
    this.requireDriverAccess(authenticatedDriverId, body.driverId)
    const driverId = authenticatedDriverId!
    await this.driversService.setDriverStatus(driverId, DriverStatus.OFFLINE)
    return { success: true, status: DriverStatus.OFFLINE }
  }

  @Post('location')
  async updateLocation(
    @Headers('x-user-id') authenticatedDriverId: string | undefined,
    @Body() body: { driverId?: string; latitude?: number; longitude?: number },
  ) {
    this.requireDriverAccess(authenticatedDriverId, body.driverId)
    if (
      !Number.isFinite(Number(body.latitude)) ||
      !Number.isFinite(Number(body.longitude))
    ) {
      throw new BadRequestException('latitude and longitude are required')
    }
    const driverId = authenticatedDriverId!
    await this.driversService.updateLocation(
      driverId,
      Number(body.latitude),
      Number(body.longitude),
      DriverStatus.ONLINE,
    )
    return { success: true }
  }

  private requireDriverAccess(
    authenticatedDriverId?: string,
    bodyDriverId?: string,
  ) {
    if (!authenticatedDriverId || !bodyDriverId) {
      throw new BadRequestException('driverId is required')
    }
    if (authenticatedDriverId !== bodyDriverId) {
      throw new BadRequestException('driverId must match authenticated driver')
    }
  }
}
