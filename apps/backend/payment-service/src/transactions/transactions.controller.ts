import { Controller, Get, Param, Query } from '@nestjs/common'
import { TransactionsService } from './transactions.service'
import { TransactionStatus, TransactionType } from './entities/transaction.entity'

@Controller('transactions')
export class TransactionsController {
  constructor(private readonly service: TransactionsService) {}

  @Get()
  listAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('type') type?: TransactionType,
    @Query('status') status?: TransactionStatus,
    @Query('fromDate') fromDate?: string,
    @Query('toDate') toDate?: string,
  ) {
    return this.service.listAll({
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      type,
      status,
      fromDate: fromDate ? new Date(fromDate) : undefined,
      toDate: toDate ? new Date(toDate) : undefined,
    })
  }

  @Get('user/:userId')
  list(
    @Param('userId') userId: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('type') type?: TransactionType,
    @Query('status') status?: TransactionStatus,
  ) {
    return this.service.listByUser(userId, {
      page: page ? +page : 1,
      limit: limit ? +limit : 20,
      type,
      status,
    })
  }

  @Get('user/:userId/summary')
  summary(@Param('userId') userId: string) {
    return this.service.getSummary(userId)
  }

  @Get('reference/:referenceId')
  byReference(@Param('referenceId') referenceId: string) {
    return this.service.listByReference(referenceId)
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findById(id)
  }
}
