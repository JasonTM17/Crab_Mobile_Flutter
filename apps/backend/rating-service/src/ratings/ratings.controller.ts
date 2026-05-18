import { Body, Controller, Get, Param, Post, Put, Query } from '@nestjs/common'
import { RatingsService } from './ratings.service'
import { CreateRatingDto, FlagRatingDto } from './dto/rating.dto'
import { RatingTargetType } from './entities/rating.entity'

@Controller('ratings')
export class RatingsController {
  constructor(private readonly service: RatingsService) {}

  @Post()
  create(@Body() dto: CreateRatingDto) {
    return this.service.create(dto)
  }

  @Get('target/:targetType/:targetId')
  listForTarget(
    @Param('targetType') targetType: RatingTargetType,
    @Param('targetId') targetId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('minScore') minScore?: string,
  ) {
    return this.service.listForTarget(
      targetId,
      targetType,
      page ? +page : 1,
      limit ? +limit : 20,
      minScore ? +minScore : undefined,
    )
  }

  @Get('aggregate/:targetType/:targetId')
  aggregate(
    @Param('targetType') targetType: RatingTargetType,
    @Param('targetId') targetId: string,
  ) {
    return this.service.getAggregate(targetId, targetType)
  }

  @Get('reference/:referenceId')
  byReference(@Param('referenceId') referenceId: string) {
    return this.service.findByReference(referenceId)
  }

  @Get('rater/:raterId')
  byRater(@Param('raterId') raterId: string, @Query('limit') limit?: string) {
    return this.service.findByRater(raterId, limit ? +limit : 50)
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findById(id)
  }

  @Put(':id/flag')
  flag(@Param('id') id: string, @Body() dto: FlagRatingDto) {
    return this.service.flag(id, dto)
  }

  @Put(':id/hide')
  hide(@Param('id') id: string) {
    return this.service.hide(id)
  }
}
