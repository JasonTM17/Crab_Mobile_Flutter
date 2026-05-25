import {
  Body,
  Controller,
  Delete,
  ForbiddenException,
  Get,
  Headers,
  Param,
  Post,
  Put,
  Query,
  UnauthorizedException,
} from '@nestjs/common'
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
    @Headers('x-user-id') authenticatedUserId: string | undefined,
    @Param('userId') userId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('unreadOnly') unreadOnly?: string,
  ) {
    this.assertUserAccess(authenticatedUserId, userId)
    return this.service.list(
      authenticatedUserId!,
      page ? +page : 1,
      limit ? +limit : 30,
      unreadOnly === 'true',
    )
  }

  @Get('user/:userId/unread-count')
  unreadCount(@Headers('x-user-id') authenticatedUserId: string | undefined, @Param('userId') userId: string) {
    this.assertUserAccess(authenticatedUserId, userId)
    return this.service.unreadCount(authenticatedUserId!)
  }

  @Put(':id/read')
  markRead(@Headers('x-user-id') authenticatedUserId: string | undefined, @Param('id') id: string) {
    this.assertAuthenticated(authenticatedUserId)
    return this.service.markRead(id, authenticatedUserId!)
  }

  @Put('user/:userId/read-all')
  markAllRead(@Headers('x-user-id') authenticatedUserId: string | undefined, @Param('userId') userId: string) {
    this.assertUserAccess(authenticatedUserId, userId)
    return this.service.markAllRead(authenticatedUserId!)
  }

  @Delete(':id')
  delete(
    @Headers('x-user-id') authenticatedUserId: string | undefined,
    @Param('id') id: string,
  ): Promise<{ acknowledged: boolean; deletedCount: number }> {
    this.assertAuthenticated(authenticatedUserId)
    return this.service.delete(id, authenticatedUserId!)
  }

  private assertAuthenticated(userId: string | undefined) {
    if (!userId) throw new UnauthorizedException('Missing authenticated user')
  }

  private assertUserAccess(userId: string | undefined, routeUserId: string) {
    this.assertAuthenticated(userId)
    if (userId !== routeUserId) throw new ForbiddenException('Cannot access another user\'s notifications')
  }
}
