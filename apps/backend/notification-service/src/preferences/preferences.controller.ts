import { Body, Controller, Delete, Get, Param, Post, Put } from '@nestjs/common'
import { FcmTokenDto, UpdatePreferencesDto } from './dto/preferences.dto'
import { PreferencesService } from './preferences.service'

@Controller('notifications/preferences')
export class PreferencesController {
  constructor(private readonly service: PreferencesService) {}

  @Get(':userId')
  get(@Param('userId') userId: string) {
    return this.service.getOrCreate(userId)
  }

  @Put(':userId')
  update(@Param('userId') userId: string, @Body() body: UpdatePreferencesDto) {
    return this.service.update(userId, body)
  }

  @Post(':userId/fcm-tokens')
  addToken(@Param('userId') userId: string, @Body() body: FcmTokenDto) {
    return this.service.addFcmToken(userId, body.token)
  }

  @Delete(':userId/fcm-tokens')
  removeToken(@Param('userId') userId: string, @Body() body: FcmTokenDto) {
    return this.service.removeFcmToken(userId, body.token)
  }
}
