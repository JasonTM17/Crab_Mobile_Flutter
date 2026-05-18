import { Controller, Get, Post, Patch, Param, Body, Query, HttpStatus } from '@nestjs/common'
import { OrdersService } from './orders.service'
import { CreateOrderDto } from './dto/create-order.dto'
import { UpdateOrderStatusDto } from './dto/update-order-status.dto'

@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  async create(@Body() dto: CreateOrderDto) {
    const order = await this.ordersService.create(dto)
    return { success: true, data: order, statusCode: HttpStatus.CREATED }
  }

  @Get(':id')
  async findById(@Param('id') id: string) {
    const order = await this.ordersService.findById(id)
    return { success: true, data: order, statusCode: HttpStatus.OK }
  }

  @Get()
  async findByUser(@Query('user_id') userId: string) {
    const orders = await this.ordersService.findActiveByUser(userId)
    return { success: true, data: orders, statusCode: HttpStatus.OK }
  }

  @Patch(':id/status')
  async updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateOrderStatusDto,
  ) {
    const order = await this.ordersService.updateStatus(id, dto.status, dto.driver_id)
    return { success: true, data: order, statusCode: HttpStatus.OK }
  }
}
