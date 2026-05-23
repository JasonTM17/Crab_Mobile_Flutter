import { Body, Controller, Delete, Get, Param, Post, Put, Query } from '@nestjs/common'
import { NotificationsService } from './notifications.service'
import { CreateNotificationDto, BroadcastDto } from './dto/notification.dto'

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly service: NotificationsService) {}

  @Post()
  send(@Body() dto: CreateNotificationDto) {
    return this.service.send(dto)
  }

  @Post('broadcast')
  broadcast(@Body() dto: BroadcastDto) {
    return this.service.broadcast(dto)
  }

  @Get('user/:userId')
  list(
    @Param('userId') userId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('unreadOnly') unreadOnly?: string,
  ) {
    return this.service.list(
      userId,
      page ? +page : 1,
      limit ? +limit : 30,
      unreadOnly === 'true',
    )
  }

  @Get('user/:userId/unread-count')
  unreadCount(@Param('userId') userId: string) {
    return this.service.unreadCount(userId)
  }

  @Put(':id/read')
  markRead(@Param('id') id: string, @Body('userId') userId: string) {
    return this.service.markRead(id, userId)
  }

  @Put('user/:userId/read-all')
  markAllRead(@Param('userId') userId: string) {
    return this.service.markAllRead(userId)
  }

  @Delete(':id')
  delete(
    @Param('id') id: string,
    @Body('userId') userId: string,
  ): Promise<{ acknowledged: boolean; deletedCount: number }> {
    return this.service.delete(id, userId)
  }
}
