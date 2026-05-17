import { Controller, Get, Post, Param, Body, Query, HttpStatus } from '@nestjs/common'
import { TransactionsService } from './transactions.service'

@Controller('transactions')
export class TransactionsController {
  constructor(private readonly transactionsService: TransactionsService) {}

  @Post('payment')
  async createPayment(
    @Body() body: { user_id: string; amount: number; reference_id?: string; description?: string },
  ) {
    const tx = await this.transactionsService.createPayment(
      body.user_id,
      body.amount,
      body.reference_id,
      body.description,
    )
    return { success: true, data: tx, statusCode: HttpStatus.CREATED }
  }

  @Post('topup')
  async createTopUp(
    @Body() body: { user_id: string; amount: number; description?: string },
  ) {
    const tx = await this.transactionsService.createTopUp(
      body.user_id,
      body.amount,
      body.description,
    )
    return { success: true, data: tx, statusCode: HttpStatus.CREATED }
  }

  @Post('refund')
  async createRefund(
    @Body() body: { user_id: string; amount: number; reference_id: string },
  ) {
    const tx = await this.transactionsService.createRefund(
      body.user_id,
      body.amount,
      body.reference_id,
    )
    return { success: true, data: tx, statusCode: HttpStatus.CREATED }
  }

  @Get(':userId')
  async getHistory(
    @Param('userId') userId: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    const txs = await this.transactionsService.getHistory(
      userId,
      limit ? parseInt(limit) : 20,
      offset ? parseInt(offset) : 0,
    )
    return { success: true, data: txs, statusCode: HttpStatus.OK }
  }
}
