import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { OrdersController } from './orders.controller'
import { OrdersService } from './orders.service'
import { OrderEntity } from './entities/order.entity'
import { OrderItemEntity } from './entities/order-item.entity'
import { MenuItemEntity } from '../menus/entities/menu-item.entity'
import { RestaurantEntity } from '../restaurants/entities/restaurant.entity'

@Module({
  imports: [
    TypeOrmModule.forFeature([
      OrderEntity,
      OrderItemEntity,
      MenuItemEntity,
      RestaurantEntity,
    ]),
  ],
  controllers: [OrdersController],
  providers: [OrdersService],
  exports: [OrdersService],
})
export class OrdersModule {}
