import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  Headers,
} from '@nestjs/common'
import { RatingsService } from './ratings.service'
import { CreateRatingDto } from './dto/create-rating.dto'

@Controller('ratings')
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Post()
  create(
    @Headers('x-user-id') userId: string,
    @Body() dto: CreateRatingDto,
  ) {
    return this.ratingsService.create(userId, dto)
  }

  @Get('average/:targetType/:targetId')
  getAverage(
    @Param('targetType') targetType: string,
    @Param('targetId') targetId: string,
  ) {
    return this.ratingsService.getAverageRating(targetType, targetId)
  }

  @Get('user')
  getUserRatings(@Headers('x-user-id') userId: string) {
    return this.ratingsService.getUserRatings(userId)
  }

  @Get(':targetType/:targetId')
  getTargetRatings(
    @Param('targetType') targetType: string,
    @Param('targetId') targetId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return this.ratingsService.getTargetRatings(
      targetType,
      targetId,
      +page,
      +limit,
    )
  }
}
