import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { MongooseModule } from '@nestjs/mongoose'
import { Redis } from 'ioredis'
import { ObservabilityModule, ResilienceModule } from '@crab/backend-shared'
import { RoomsModule } from './rooms/rooms.module'
import { MessagesModule } from './messages/messages.module'
import { HealthController } from './health.controller'

const REDIS_CLIENT = 'CHAT_REDIS_CLIENT'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ObservabilityModule,
    ResilienceModule.forRoot({ redis: { inject: REDIS_CLIENT } }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGODB_URI', 'mongodb://localhost:27017/crab_chat'),
      }),
    }),
    RoomsModule,
    MessagesModule,
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
