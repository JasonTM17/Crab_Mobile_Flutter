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
  UnauthorizedException,
} from '@nestjs/common'
import { FcmTokenDto, UpdatePreferencesDto } from './dto/preferences.dto'
import { PreferencesService } from './preferences.service'

@Controller('notifications/preferences')
export class PreferencesController {
  constructor(private readonly service: PreferencesService) {}

  @Get(':userId')
  get(@Headers('x-user-id') authenticatedUserId: string | undefined, @Param('userId') userId: string) {
    this.assertUserAccess(authenticatedUserId, userId)
    return this.service.getOrCreate(authenticatedUserId!)
  }

  @Put(':userId')
  update(@Headers('x-user-id') authenticatedUserId: string | undefined, @Param('userId') userId: string, @Body() body: UpdatePreferencesDto) {
    this.assertUserAccess(authenticatedUserId, userId)
    return this.service.update(authenticatedUserId!, body)
  }

  @Post(':userId/fcm-tokens')
  addToken(@Headers('x-user-id') authenticatedUserId: string | undefined, @Param('userId') userId: string, @Body() body: FcmTokenDto) {
    this.assertUserAccess(authenticatedUserId, userId)
    return this.service.addFcmToken(authenticatedUserId!, body.token)
  }

  @Delete(':userId/fcm-tokens')
  removeToken(@Headers('x-user-id') authenticatedUserId: string | undefined, @Param('userId') userId: string, @Body() body: FcmTokenDto) {
    this.assertUserAccess(authenticatedUserId, userId)
    return this.service.removeFcmToken(authenticatedUserId!, body.token)
  }

  private assertAuthenticated(userId: string | undefined) {
    if (!userId) throw new UnauthorizedException('Missing authenticated user')
  }

  private assertUserAccess(userId: string | undefined, routeUserId: string) {
    this.assertAuthenticated(userId)
    if (userId !== routeUserId) throw new ForbiddenException('Cannot access another user\'s preferences')
  }
}
