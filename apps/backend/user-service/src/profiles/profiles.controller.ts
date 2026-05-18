import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
} from '@nestjs/common'
import { ProfilesService } from './profiles.service'
import { CreateProfileDto, UpdateProfileDto } from './dto/update-profile.dto'

@Controller('profiles')
export class ProfilesController {
  constructor(private readonly service: ProfilesService) {}

  @Post()
  create(@Body() dto: CreateProfileDto) {
    return this.service.create(dto)
  }

  @Get()
  list(@Query('page') page?: string, @Query('limit') limit?: string) {
    return this.service.list(page ? +page : 1, limit ? +limit : 20)
  }

  @Get(':userId')
  findOne(@Param('userId') userId: string) {
    return this.service.findById(userId)
  }

  @Put(':userId')
  update(@Param('userId') userId: string, @Body() dto: UpdateProfileDto) {
    return this.service.update(userId, dto)
  }

  @Delete(':userId')
  delete(@Param('userId') userId: string) {
    return this.service.delete(userId)
  }
}
