import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { MenusController } from './menus.controller'
import { MenusService } from './menus.service'
import { MenuCategoryEntity } from './entities/menu-category.entity'
import { MenuItemEntity } from './entities/menu-item.entity'

@Module({
  imports: [TypeOrmModule.forFeature([MenuCategoryEntity, MenuItemEntity])],
  controllers: [MenusController],
  providers: [MenusService],
  exports: [MenusService],
})
export class MenusModule {}
