import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  Query,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common'
import { RidesService } from './rides.service'
import { CreateRideDto } from './dto/create-ride.dto'
import { UpdateRideStatusDto } from './dto/update-ride-status.dto'
import { CancelRideDto } from './dto/cancel-ride.dto'
import { SosDto } from './dto/sos.dto'

@Controller('rides')
export class RidesController {
  constructor(private readonly ridesService: RidesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() dto: CreateRideDto) {
    const ride = await this.ridesService.create(dto)
    return { success: true, data: ride, statusCode: HttpStatus.CREATED }
  }

  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    const ride = await this.ridesService.findById(id)
    return { success: true, data: ride, statusCode: HttpStatus.OK }
  }

  @Get('rider/:riderId')
  async findByRider(@Param('riderId', ParseUUIDPipe) riderId: string) {
    const rides = await this.ridesService.findByRider(riderId)
    return { success: true, data: rides, statusCode: HttpStatus.OK }
  }

  @Patch(':id/status')
  async updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateRideStatusDto,
  ) {
    const ride = await this.ridesService.updateStatus(id, dto)
    return { success: true, data: ride, statusCode: HttpStatus.OK }
  }

  @Post(':id/accept')
  async accept(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: { driverId: string },
  ) {
    const ride = await this.ridesService.acceptRide(id, body.driverId)
    return { success: true, data: ride, statusCode: HttpStatus.OK }
  }

  @Post(':id/reject')
  async reject(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: { driverId: string },
  ) {
    const ride = await this.ridesService.rejectRide(id, body.driverId)
    return { success: true, data: ride, statusCode: HttpStatus.OK }
  }

  @Post(':id/cancel')
  cancel(@Param('id') id: string, @Body() dto: CancelRideDto) {
    return this.ridesService.cancelRide(id, dto.reason)
  }

  @Post(':id/sos')
  sos(@Param('id') id: string, @Body() dto: SosDto) {
    return this.ridesService.triggerSos(id, dto.latitude, dto.longitude)
  }

  @Get('active/driver/:driverId')
  activeForDriver(@Param('driverId') driverId: string) {
    return this.ridesService.findActiveByDriver(driverId)
  }

  @Get('active/rider/:riderId')
  activeForRider(@Param('riderId') riderId: string) {
    return this.ridesService.findActiveByRider(riderId)
  }

  @Get('stats/driver/:driverId')
  driverStats(
    @Param('driverId') driverId: string,
    @Query('days') days?: string,
  ) {
    return this.ridesService.getStats(driverId, days ? +days : 7)
  }
}
