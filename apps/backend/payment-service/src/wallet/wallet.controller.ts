import { Body, Controller, Get, Param, Post, Put } from '@nestjs/common'
import { WalletService } from './wallet.service'
import { TopUpDto, WithdrawDto, TransferDto } from './dto/wallet.dto'

@Controller('wallet')
export class WalletController {
  constructor(private readonly service: WalletService) {}

  @Get(':userId')
  getBalance(@Param('userId') userId: string) {
    return this.service.getBalance(userId)
  }

  @Post(':userId/top-up')
  topUp(@Param('userId') userId: string, @Body() dto: TopUpDto) {
    return this.service.topUp(userId, dto)
  }

  @Post(':userId/withdraw')
  withdraw(@Param('userId') userId: string, @Body() dto: WithdrawDto) {
    return this.service.withdraw(userId, dto)
  }

  @Post(':userId/transfer')
  transfer(@Param('userId') userId: string, @Body() dto: TransferDto) {
    return this.service.transfer(userId, dto)
  }

  @Put(':userId/freeze')
  freeze(@Param('userId') userId: string) {
    return this.service.freeze(userId)
  }

  @Put(':userId/unfreeze')
  unfreeze(@Param('userId') userId: string) {
    return this.service.unfreeze(userId)
  }
}
