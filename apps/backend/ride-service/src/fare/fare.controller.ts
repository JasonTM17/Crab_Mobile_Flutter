import { Controller, Post, Body } from '@nestjs/common'
import { FareService } from './fare.service'
import { EstimateFareDto } from './dto/estimate-fare.dto'

@Controller('rides/estimate')
export class FareController {
  constructor(private readonly fareService: FareService) {}

  @Post()
  estimate(@Body() dto: EstimateFareDto) {
    if (dto.vehicle_type) {
      return this.fareService.estimate(
        dto.pickup_lat,
        dto.pickup_lng,
        dto.dropoff_lat,
        dto.dropoff_lng,
        1.0,
        dto.vehicle_type,
      )
    }
    return this.fareService.estimateAllTypes(
      dto.pickup_lat,
      dto.pickup_lng,
      dto.dropoff_lat,
      dto.dropoff_lng,
    )
  }
}
