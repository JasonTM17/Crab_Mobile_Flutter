import { Module } from '@nestjs/common'
import { ConfigModule, ConfigService } from '@nestjs/config'
import { TypeOrmModule } from '@nestjs/typeorm'
import { WalletModule } from './wallet/wallet.module'
import { TransactionsModule } from './transactions/transactions.module'
import { PromoModule } from './promo/promo.module'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        url: config.get('DATABASE_URL', 'postgresql://crab:crab@localhost:5432/crab'),
        autoLoadEntities: true,
        synchronize: config.get('NODE_ENV') !== 'production',
      }),
    }),
    WalletModule,
    TransactionsModule,
    PromoModule,
  ],
})
export class AppModule {}
