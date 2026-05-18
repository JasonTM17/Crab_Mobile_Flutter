import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { PromoController } from './promo.controller'
import { PromoService } from './promo.service'
import { PromoEntity, PromoUsageEntity } from './entities/promo.entity'

@Module({
  imports: [TypeOrmModule.forFeature([PromoEntity, PromoUsageEntity])],
  controllers: [PromoController],
  providers: [PromoService],
  exports: [PromoService],
})
export class PromoModule {}
