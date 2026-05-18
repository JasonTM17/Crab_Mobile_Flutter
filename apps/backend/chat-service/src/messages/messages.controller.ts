import { Body, Controller, Delete, Get, Param, Post, Put, Query } from '@nestjs/common'
import { MessagesService } from './messages.service'
import { SendMessageDto, EditMessageDto } from './dto/message.dto'

@Controller('chats/messages')
export class MessagesController {
  constructor(private readonly service: MessagesService) {}

  @Post()
  send(@Body() dto: SendMessageDto) {
    return this.service.send(dto)
  }

  @Get('room/:roomId')
  list(
    @Param('roomId') roomId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.service.list(roomId, page ? +page : 1, limit ? +limit : 50)
  }

  @Put(':id/read')
  markRead(@Param('id') id: string, @Body('userId') userId: string) {
    return this.service.markAsRead(id, userId)
  }

  @Put('room/:roomId/read')
  markRoomRead(@Param('roomId') roomId: string, @Body('userId') userId: string) {
    return this.service.markRoomAsRead(roomId, userId)
  }

  @Put(':id/edit')
  edit(
    @Param('id') id: string,
    @Body('userId') userId: string,
    @Body() dto: EditMessageDto,
  ) {
    return this.service.edit(id, userId, dto)
  }

  @Delete(':id')
  delete(@Param('id') id: string, @Body('userId') userId: string) {
    return this.service.delete(id, userId)
  }
}
