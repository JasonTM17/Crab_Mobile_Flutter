import { Controller, Get, Post, Param, Body, HttpStatus } from '@nestjs/common'
import { ConversationsService } from './conversations.service'

@Controller('conversations')
export class ConversationsController {
  constructor(private readonly conversationsService: ConversationsService) {}

  @Get('user/:userId')
  async getByUser(@Param('userId') userId: string) {
    const conversations = await this.conversationsService.getByUser(userId)
    return { success: true, data: conversations, statusCode: HttpStatus.OK }
  }

  @Post()
  async findOrCreate(
    @Body() body: { participants: string[]; context_type: string; context_id?: string },
  ) {
    const conversation = await this.conversationsService.findOrCreate(
      body.participants,
      body.context_type,
      body.context_id,
    )
    return { success: true, data: conversation, statusCode: HttpStatus.CREATED }
  }
}
