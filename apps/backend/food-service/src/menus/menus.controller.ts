import { Controller, Get, Post, Patch, Param, Body, HttpStatus } from '@nestjs/common'
import { MenusService } from './menus.service'
import { CreateMenuItemDto } from './dto/create-menu-item.dto'

@Controller()
export class MenusController {
  constructor(private readonly menusService: MenusService) {}

  @Get('restaurants/:restaurantId/menu')
  async getMenu(@Param('restaurantId') restaurantId: string) {
    const items = await this.menusService.getMenuByRestaurant(restaurantId)
    return { success: true, data: items, statusCode: HttpStatus.OK }
  }

  @Post('menus/items')
  async createItem(@Body() dto: CreateMenuItemDto) {
    const item = await this.menusService.createItem(dto)
    return { success: true, data: item, statusCode: HttpStatus.CREATED }
  }

  @Patch('menus/items/:id')
  async updateItem(@Param('id') id: string, @Body() body: any) {
    const item = await this.menusService.updateItem(id, body)
    return { success: true, data: item, statusCode: HttpStatus.OK }
  }
}
