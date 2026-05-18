import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { PromoCodeEntity } from './entities/promo-code.entity'
import { PromoController } from './promo.controller'
import { PromoService } from './promo.service'

@Module({
  imports: [TypeOrmModule.forFeature([PromoCodeEntity])],
  controllers: [PromoController],
  providers: [PromoService],
  exports: [PromoService],
})
export class PromoModule {}
