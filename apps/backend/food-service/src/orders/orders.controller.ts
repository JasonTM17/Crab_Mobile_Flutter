import { Body, Controller, Get, Param, Post, Put, Query } from '@nestjs/common'
import { OrdersService } from './orders.service'
import { CreateOrderDto, UpdateOrderStatusDto } from './dto/order.dto'
import { OrderStatus } from '@crab/common-types'

@Controller('orders')
export class OrdersController {
  constructor(private readonly service: OrdersService) {}

  @Post()
  create(@Body() dto: CreateOrderDto) {
    return this.service.create(dto)
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findById(id)
  }

  @Get('customer/:customerId')
  byCustomer(@Param('customerId') customerId: string, @Query('limit') limit?: string) {
    return this.service.findByCustomer(customerId, limit ? +limit : 50)
  }

  @Get('customer/:customerId/active')
  active(@Param('customerId') customerId: string) {
    return this.service.findActive(customerId)
  }

  @Get('restaurant/:restaurantId')
  byRestaurant(
    @Param('restaurantId') restaurantId: string,
    @Query('status') status?: OrderStatus,
  ) {
    return this.service.findByRestaurant(restaurantId, status)
  }

  @Get('driver/:driverId')
  byDriver(@Param('driverId') driverId: string, @Query('limit') limit?: string) {
    return this.service.findByDriver(driverId, limit ? +limit : 50)
  }

  @Put(':id/status')
  updateStatus(@Param('id') id: string, @Body() dto: UpdateOrderStatusDto) {
    return this.service.updateStatus(id, dto)
  }

  @Put(':id/assign-driver')
  assign(@Param('id') id: string, @Body('driverId') driverId: string) {
    return this.service.assignDriver(id, driverId)
  }

  @Get('stats/restaurant/:restaurantId')
  stats(@Param('restaurantId') restaurantId: string, @Query('days') days?: string) {
    return this.service.getStats(restaurantId, days ? +days : 30)
  }
}
