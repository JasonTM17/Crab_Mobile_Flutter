import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { MongooseModule } from '@nestjs/mongoose'
import { ConversationsModule } from './conversations/conversations.module'
import { MessagesModule } from './messages/messages.module'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    MongooseModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: config.get('MONGODB_URI', 'mongodb://localhost:27017/crab_chat'),
      }),
    }),
    ConversationsModule,
    MessagesModule,
  ],
})
export class AppModule {}
