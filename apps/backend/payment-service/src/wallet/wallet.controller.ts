import { Controller, Get, Post, Param, Body, HttpStatus } from '@nestjs/common'
import { WalletService } from './wallet.service'

@Controller('wallet')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Get(':userId')
  async getBalance(@Param('userId') userId: string) {
    const balance = await this.walletService.getBalance(userId)
    return { success: true, data: { balance }, statusCode: HttpStatus.OK }
  }

  @Post(':userId/topup')
  async topUp(@Param('userId') userId: string, @Body('amount') amount: number) {
    const wallet = await this.walletService.topUp(userId, amount)
    return { success: true, data: wallet, statusCode: HttpStatus.OK }
  }

  @Post(':userId/withdraw')
  async withdraw(@Param('userId') userId: string, @Body('amount') amount: number) {
    const wallet = await this.walletService.withdraw(userId, amount)
    return { success: true, data: wallet, statusCode: HttpStatus.OK }
  }
}
