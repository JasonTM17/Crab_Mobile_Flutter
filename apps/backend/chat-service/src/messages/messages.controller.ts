import { Controller, Get, Post, Param, Body, Query, HttpStatus } from '@nestjs/common'
import { MessagesService } from './messages.service'

@Controller('messages')
export class MessagesController {
  constructor(private readonly messagesService: MessagesService) {}

  @Get(':conversationId')
  async getMessages(
    @Param('conversationId') conversationId: string,
    @Query('limit') limit?: string,
    @Query('before') before?: string,
  ) {
    const messages = await this.messagesService.getByConversation(
      conversationId,
      limit ? parseInt(limit) : 50,
      before ? new Date(before) : undefined,
    )
    return { success: true, data: messages, statusCode: HttpStatus.OK }
  }

  @Post(':conversationId')
  async sendMessage(
    @Param('conversationId') conversationId: string,
    @Body() body: { sender_id: string; content: string; type?: string },
  ) {
    const message = await this.messagesService.create(
      conversationId,
      body.sender_id,
      body.content,
      body.type,
    )
    return { success: true, data: message, statusCode: HttpStatus.CREATED }
  }

  @Post(':conversationId/read')
  async markRead(
    @Param('conversationId') conversationId: string,
    @Body('user_id') userId: string,
  ) {
    await this.messagesService.markAsRead(conversationId, userId)
    return { success: true, statusCode: HttpStatus.OK }
  }
}
