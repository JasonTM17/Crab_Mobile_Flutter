import { Controller, Get, Post, Patch, Param, Query, Body, HttpStatus } from '@nestjs/common'
import { NotificationsService } from './notifications.service'

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get(':userId')
  async getByUser(
    @Param('userId') userId: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    const notifications = await this.notificationsService.getByUser(
      userId,
      limit ? parseInt(limit) : 30,
      offset ? parseInt(offset) : 0,
    )
    return { success: true, data: notifications, statusCode: HttpStatus.OK }
  }

  @Get(':userId/unread-count')
  async getUnreadCount(@Param('userId') userId: string) {
    const count = await this.notificationsService.getUnreadCount(userId)
    return { success: true, data: { count }, statusCode: HttpStatus.OK }
  }

  @Patch(':id/read')
  async markAsRead(@Param('id') id: string) {
    await this.notificationsService.markAsRead(id)
    return { success: true, statusCode: HttpStatus.OK }
  }

  @Post(':userId/read-all')
  async markAllAsRead(@Param('userId') userId: string) {
    await this.notificationsService.markAllAsRead(userId)
    return { success: true, statusCode: HttpStatus.OK }
  }
}
