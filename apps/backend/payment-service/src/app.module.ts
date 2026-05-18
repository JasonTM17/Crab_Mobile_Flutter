import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { WalletModule } from './wallet/wallet.module'
import { TransactionsModule } from './transactions/transactions.module'
import { PromoModule } from './promo/promo.module'
import { HealthController } from './health.controller'
import { WalletEntity } from './wallet/entities/wallet.entity'
import { TransactionEntity } from './transactions/entities/transaction.entity'
import { PromoEntity, PromoUsageEntity } from './promo/entities/promo.entity'

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
        entities: [WalletEntity, TransactionEntity, PromoEntity, PromoUsageEntity],
        synchronize: config.get('NODE_ENV') !== 'production',
      }),
    }),
    WalletModule,
    TransactionsModule,
    PromoModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
