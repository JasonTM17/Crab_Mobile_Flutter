import { Injectable, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { MenuCategoryEntity } from './entities/menu-category.entity'
import { MenuItemEntity } from './entities/menu-item.entity'
import {
  CreateCategoryDto,
  UpdateCategoryDto,
  CreateMenuItemDto,
  UpdateMenuItemDto,
} from './dto/menu.dto'

@Injectable()
export class MenusService {
  constructor(
    @InjectRepository(MenuCategoryEntity)
    private readonly catRepo: Repository<MenuCategoryEntity>,
    @InjectRepository(MenuItemEntity)
    private readonly itemRepo: Repository<MenuItemEntity>,
  ) {}

  async createCategory(dto: CreateCategoryDto) {
    const cat = this.catRepo.create(dto)
    return this.catRepo.save(cat)
  }

  async listCategories(restaurantId: string) {
    return this.catRepo.find({
      where: { restaurantId, isActive: true },
      order: { sortOrder: 'ASC' },
    })
  }

  async updateCategory(id: string, dto: UpdateCategoryDto) {
    await this.catRepo.update(id, dto as any)
    const c = await this.catRepo.findOne({ where: { id } })
    if (!c) throw new NotFoundException()
    return c
  }

  async deleteCategory(id: string) {
    await this.catRepo.update(id, { isActive: false })
  }

  async createItem(dto: CreateMenuItemDto) {
    const item = this.itemRepo.create(dto)
    return this.itemRepo.save(item)
  }

  async findItem(id: string) {
    const item = await this.itemRepo.findOne({ where: { id } })
    if (!item) throw new NotFoundException(`Item ${id} not found`)
    return item
  }

  async listItems(restaurantId: string, categoryId?: string) {
    const where: any = { restaurantId, isAvailable: true }
    if (categoryId) where.categoryId = categoryId
    return this.itemRepo.find({
      where,
      order: { isFeatured: 'DESC', totalSold: 'DESC' },
    })
  }

  async updateItem(id: string, dto: UpdateMenuItemDto) {
    await this.itemRepo.update(id, dto as any)
    return this.findItem(id)
  }

  async deleteItem(id: string) {
    await this.itemRepo.delete(id)
  }

  async getMenuTree(restaurantId: string) {
    const categories = await this.listCategories(restaurantId)
    const result: Array<{ category: MenuCategoryEntity; items: MenuItemEntity[] }> = []
    for (const c of categories) {
      const items = await this.itemRepo.find({
        where: { categoryId: c.id, isAvailable: true },
        order: { isFeatured: 'DESC' },
      })
      result.push({ category: c, items })
    }
    return result
  }

  async incrementSold(itemId: string, qty: number) {
    await this.itemRepo.increment({ id: itemId }, 'totalSold', qty)
  }
}
