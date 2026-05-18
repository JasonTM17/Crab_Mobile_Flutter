import { Body, Controller, Delete, Get, Param, Post, Put } from '@nestjs/common'
import { PreferencesService } from './preferences.service'

@Controller('notifications/preferences')
export class PreferencesController {
  constructor(private readonly service: PreferencesService) {}

  @Get(':userId')
  get(@Param('userId') userId: string) {
    return this.service.getOrCreate(userId)
  }

  @Put(':userId')
  update(@Param('userId') userId: string, @Body() body: any) {
    return this.service.update(userId, body)
  }

  @Post(':userId/fcm-tokens')
  addToken(@Param('userId') userId: string, @Body('token') token: string) {
    return this.service.addFcmToken(userId, token)
  }

  @Delete(':userId/fcm-tokens')
  removeToken(@Param('userId') userId: string, @Body('token') token: string) {
    return this.service.removeFcmToken(userId, token)
  }
}
