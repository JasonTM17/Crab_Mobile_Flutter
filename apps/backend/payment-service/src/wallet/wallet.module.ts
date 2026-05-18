import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { WalletController } from './wallet.controller'
import { WalletService } from './wallet.service'
import { WalletEntity } from './entities/wallet.entity'
import { TransactionEntity } from '../transactions/entities/transaction.entity'

@Module({
  imports: [TypeOrmModule.forFeature([WalletEntity, TransactionEntity])],
  controllers: [WalletController],
  providers: [WalletService],
  exports: [WalletService],
})
export class WalletModule {}
