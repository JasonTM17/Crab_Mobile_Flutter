import { Body, Controller, Delete, Get, Param, Post, Put, Query } from '@nestjs/common'
import { RestaurantsService } from './restaurants.service'
import {
  CreateRestaurantDto,
  UpdateRestaurantDto,
  SearchRestaurantsDto,
} from './dto/restaurant.dto'

@Controller('restaurants')
export class RestaurantsController {
  constructor(private readonly service: RestaurantsService) {}

  @Post()
  create(@Body() dto: CreateRestaurantDto) {
    return this.service.create(dto)
  }

  @Get('search')
  search(@Query() dto: SearchRestaurantsDto) {
    return this.service.search(dto)
  }

  @Get('featured')
  featured(@Query('limit') limit?: string) {
    return this.service.findFeatured(limit ? +limit : 10)
  }

  @Get('merchant/:merchantId')
  byMerchant(@Param('merchantId') merchantId: string) {
    return this.service.findByMerchant(merchantId)
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findById(id)
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() dto: UpdateRestaurantDto) {
    return this.service.update(id, dto)
  }

  @Put(':id/toggle-open')
  toggle(@Param('id') id: string, @Body('isOpen') isOpen: boolean) {
    return this.service.toggleOpen(id, isOpen)
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.service.delete(id)
  }
}
