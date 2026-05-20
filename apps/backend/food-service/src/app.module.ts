import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { MongooseModule } from '@nestjs/mongoose'
import { Redis } from 'ioredis'
import { ObservabilityModule, ResilienceModule } from '@crab/backend-shared'
import { RestaurantsModule } from './restaurants/restaurants.module'
import { MenusModule } from './menus/menus.module'
import { OrdersModule } from './orders/orders.module'
import { HealthController } from './health.controller'
import { RestaurantEntity } from './restaurants/entities/restaurant.entity'
import { MenuCategoryEntity } from './menus/entities/menu-category.entity'
import { MenuItemEntity } from './menus/entities/menu-item.entity'
import { OrderEntity } from './orders/entities/order.entity'
import { OrderItemEntity } from './orders/entities/order-item.entity'

const REDIS_CLIENT = 'FOOD_REDIS_CLIENT'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ObservabilityModule,
    ResilienceModule.forRoot({ redis: { inject: REDIS_CLIENT } }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const url = config.get<string>('DATABASE_URL')
        return {
          type: 'postgres' as const,
          ...(url
            ? { url }
            : {
                host: config.get<string>('DB_HOST', 'localhost'),
                port: config.get<number>('DB_PORT', 5432),
                username: config.get<string>('DB_USER', 'crab'),
                password: config.get<string>('DB_PASSWORD', 'crab_secret'),
                database: config.get<string>('DB_NAME', 'crab_db'),
              }),
          entities: [
            RestaurantEntity,
            MenuCategoryEntity,
            MenuItemEntity,
            OrderEntity,
            OrderItemEntity,
          ],
          synchronize: config.get('NODE_ENV') !== 'production',
        }
      },
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
  providers: [
    {
      provide: REDIS_CLIENT,
      useFactory: () => new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379'),
    },
  ],
  exports: [REDIS_CLIENT],
})
export class AppModule {}
