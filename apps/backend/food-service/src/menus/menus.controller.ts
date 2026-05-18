import { Body, Controller, Delete, Get, Param, Post, Put, Query } from '@nestjs/common'
import { MenusService } from './menus.service'
import {
  CreateCategoryDto,
  UpdateCategoryDto,
  CreateMenuItemDto,
  UpdateMenuItemDto,
} from './dto/menu.dto'

@Controller('menus')
export class MenusController {
  constructor(private readonly service: MenusService) {}

  @Post('categories')
  createCategory(@Body() dto: CreateCategoryDto) {
    return this.service.createCategory(dto)
  }

  @Get('categories/restaurant/:restaurantId')
  listCategories(@Param('restaurantId') restaurantId: string) {
    return this.service.listCategories(restaurantId)
  }

  @Put('categories/:id')
  updateCategory(@Param('id') id: string, @Body() dto: UpdateCategoryDto) {
    return this.service.updateCategory(id, dto)
  }

  @Delete('categories/:id')
  deleteCategory(@Param('id') id: string) {
    return this.service.deleteCategory(id)
  }

  @Post('items')
  createItem(@Body() dto: CreateMenuItemDto) {
    return this.service.createItem(dto)
  }

  @Get('items/restaurant/:restaurantId')
  listItems(
    @Param('restaurantId') restaurantId: string,
    @Query('categoryId') categoryId?: string,
  ) {
    return this.service.listItems(restaurantId, categoryId)
  }

  @Get('items/:id')
  findItem(@Param('id') id: string) {
    return this.service.findItem(id)
  }

  @Put('items/:id')
  updateItem(@Param('id') id: string, @Body() dto: UpdateMenuItemDto) {
    return this.service.updateItem(id, dto)
  }

  @Delete('items/:id')
  deleteItem(@Param('id') id: string) {
    return this.service.deleteItem(id)
  }

  @Get('tree/:restaurantId')
  tree(@Param('restaurantId') restaurantId: string) {
    return this.service.getMenuTree(restaurantId)
  }
}
