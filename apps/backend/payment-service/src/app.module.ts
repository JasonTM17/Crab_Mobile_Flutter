import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { Redis } from 'ioredis'
import { ObservabilityModule, ResilienceModule } from '@crab/backend-shared'
import { WalletModule } from './wallet/wallet.module'
import { TransactionsModule } from './transactions/transactions.module'
import { PromoModule } from './promo/promo.module'
import { HealthController } from './health.controller'
import { WalletEntity } from './wallet/entities/wallet.entity'
import { TransactionEntity } from './transactions/entities/transaction.entity'
import { PromoEntity, PromoUsageEntity } from './promo/entities/promo.entity'

const REDIS_CLIENT = 'PAYMENT_REDIS_CLIENT'

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
          entities: [WalletEntity, TransactionEntity, PromoEntity, PromoUsageEntity],
          synchronize: config.get('NODE_ENV') !== 'production',
        }
      },
    }),
    WalletModule,
    TransactionsModule,
    PromoModule,
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
