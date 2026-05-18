import { Body, Controller, Get, Param, Post, Put, Query } from '@nestjs/common'
import { RoomsService } from './rooms.service'
import { CreateRoomDto } from './dto/room.dto'
import { RoomStatus } from './schemas/room.schema'

@Controller('chats/rooms')
export class RoomsController {
  constructor(private readonly service: RoomsService) {}

  @Post()
  create(@Body() dto: CreateRoomDto) {
    return this.service.create(dto)
  }

  @Get('user/:userId')
  list(@Param('userId') userId: string, @Query('status') status?: RoomStatus) {
    return this.service.listForUser(userId, status ?? RoomStatus.ACTIVE)
  }

  @Get('reference/:referenceId')
  byRef(@Param('referenceId') referenceId: string) {
    return this.service.findByReference(referenceId)
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findById(id)
  }

  @Put(':id/archive')
  archive(@Param('id') id: string) {
    return this.service.archive(id)
  }

  @Put(':id/read')
  markRead(
    @Param('id') id: string,
    @Body('userId') userId: string,
    @Body('lastMessageId') lastMessageId: string,
  ) {
    return this.service.markRead(id, userId, lastMessageId)
  }
}
