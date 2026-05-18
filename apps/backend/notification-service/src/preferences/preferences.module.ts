import { Module } from '@nestjs/common'
import { MongooseModule } from '@nestjs/mongoose'
import {
  NotificationPreferences,
  PreferencesSchema,
} from './schemas/preferences.schema'
import { PreferencesService } from './preferences.service'
import { PreferencesController } from './preferences.controller'

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: NotificationPreferences.name, schema: PreferencesSchema },
    ]),
  ],
  controllers: [PreferencesController],
  providers: [PreferencesService],
  exports: [PreferencesService],
})
export class PreferencesModule {}
