import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  Headers,
} from '@nestjs/common'
import { ReviewsService } from './reviews.service'

@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post()
  create(
    @Headers('x-user-id') userId: string,
    @Body() body: { targetType: string; targetId: string; score: number; comment?: string; tags?: string[]; rideId?: string; orderId?: string },
  ) {
    return this.reviewsService.create(userId, body)
  }

  @Get(':targetType/:targetId')
  findByTarget(
    @Param('targetType') targetType: string,
    @Param('targetId') targetId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 20,
  ) {
    return this.reviewsService.findByTarget(targetType, targetId, +page, +limit)
  }

  @Get('user')
  findByUser(@Headers('x-user-id') userId: string) {
    return this.reviewsService.findByUser(userId)
  }

  @Get('stats/:targetType/:targetId')
  getStats(
    @Param('targetType') targetType: string,
    @Param('targetId') targetId: string,
  ) {
    return this.reviewsService.getStats(targetType, targetId)
  }

  @Patch(':id/reply')
  reply(@Param('id') id: string, @Body() body: { content: string }) {
    return this.reviewsService.reply(id, body.content)
  }
}
