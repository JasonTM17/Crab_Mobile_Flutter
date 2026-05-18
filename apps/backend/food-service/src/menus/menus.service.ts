import { Injectable } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { MenuItemEntity } from './entities/menu-item.entity'
import { CreateMenuItemDto } from './dto/create-menu-item.dto'

@Injectable()
export class MenusService {
  constructor(
    @InjectRepository(MenuItemEntity)
    private readonly menuItemRepo: Repository<MenuItemEntity>,
  ) {}

  async getMenuByRestaurant(restaurantId: string) {
    return this.menuItemRepo.find({
      where: { restaurant_id: restaurantId, is_available: true },
      order: { category: 'ASC', name: 'ASC' },
    })
  }

  async createItem(dto: CreateMenuItemDto) {
    const item = this.menuItemRepo.create(dto)
    return this.menuItemRepo.save(item)
  }

  async updateItem(id: string, data: Partial<MenuItemEntity>) {
    await this.menuItemRepo.update(id, data)
    return this.menuItemRepo.findOneBy({ id })
  }
}
