import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common'
import { FareService } from './fare.service'
import { EstimateRideDto } from '../rides/dto/create-ride.dto'

@Controller('rides')
export class FareController {
  constructor(private readonly fareService: FareService) {}

  @Post('estimate')
  @HttpCode(HttpStatus.OK)
  estimate(@Body() dto: EstimateRideDto) {
    const estimate = this.fareService.estimate(
      dto.pickup_lat,
      dto.pickup_lng,
      dto.dropoff_lat,
      dto.dropoff_lng,
    )
    return { success: true, data: estimate, statusCode: HttpStatus.OK }
  }
}
