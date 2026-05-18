import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { MongooseModule } from '@nestjs/mongoose'
import { NotificationsModule } from './notifications/notifications.module'
import { PreferencesModule } from './preferences/preferences.module'
import { HealthController } from './health.controller'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGODB_URI', 'mongodb://localhost:27017/crab_notifications'),
      }),
    }),
    NotificationsModule,
    PreferencesModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
