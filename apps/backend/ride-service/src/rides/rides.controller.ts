import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common'
import { RidesService } from './rides.service'
import { CreateRideDto } from './dto/create-ride.dto'
import { UpdateRideStatusDto } from './dto/update-ride-status.dto'

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
}
