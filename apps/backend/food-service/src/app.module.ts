import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { MongooseModule } from '@nestjs/mongoose'
import { RestaurantsModule } from './restaurants/restaurants.module'
import { MenusModule } from './menus/menus.module'
import { OrdersModule } from './orders/orders.module'
import { HealthController } from './health.controller'
import { RestaurantEntity } from './restaurants/entities/restaurant.entity'
import { MenuCategoryEntity } from './menus/entities/menu-category.entity'
import { MenuItemEntity } from './menus/entities/menu-item.entity'
import { OrderEntity } from './orders/entities/order.entity'
import { OrderItemEntity } from './orders/entities/order-item.entity'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST', 'localhost'),
        port: config.get<number>('DB_PORT', 5432),
        username: config.get('DB_USER', 'crab'),
        password: config.get('DB_PASSWORD', 'crab_secret'),
        database: config.get('DB_NAME', 'crab_db'),
        entities: [
          RestaurantEntity,
          MenuCategoryEntity,
          MenuItemEntity,
          OrderEntity,
          OrderItemEntity,
        ],
        synchronize: config.get('NODE_ENV') !== 'production',
      }),
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGODB_URI', 'mongodb://localhost:27017/crab_food'),
      }),
    }),
    RestaurantsModule,
    MenusModule,
    OrdersModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
