import { Controller, Get, Post, Param, Query, Body, HttpStatus } from '@nestjs/common'
import { RestaurantsService } from './restaurants.service'
import { RestaurantCategory } from './schemas/restaurant.schema'

@Controller('restaurants')
export class RestaurantsController {
  constructor(private readonly restaurantsService: RestaurantsService) {}

  @Get()
  async findNearby(
    @Query('lat') lat: string,
    @Query('lng') lng: string,
    @Query('radius') radius?: string,
    @Query('category') category?: RestaurantCategory,
  ) {
    const restaurants = await this.restaurantsService.findNearby(
      parseFloat(lat),
      parseFloat(lng),
      radius ? parseFloat(radius) : 5,
      category,
    )
    return { success: true, data: restaurants, statusCode: HttpStatus.OK }
  }

  @Get('search')
  async search(
    @Query('q') query: string,
    @Query('lat') lat?: string,
    @Query('lng') lng?: string,
  ) {
    const restaurants = await this.restaurantsService.search(
      query,
      lat ? parseFloat(lat) : undefined,
      lng ? parseFloat(lng) : undefined,
    )
    return { success: true, data: restaurants, statusCode: HttpStatus.OK }
  }

  @Get(':id')
  async findById(@Param('id') id: string) {
    const restaurant = await this.restaurantsService.findById(id)
    return { success: true, data: restaurant, statusCode: HttpStatus.OK }
  }

  @Post()
  async create(@Body() body: any) {
    const restaurant = await this.restaurantsService.create(body)
    return { success: true, data: restaurant, statusCode: HttpStatus.CREATED }
  }
}
