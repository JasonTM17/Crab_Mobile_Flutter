import { Body, Controller, Get, Param, Post, Put, Query } from '@nestjs/common'
import { PromoService } from './promo.service'
import { CreatePromoDto, ApplyPromoDto } from './dto/promo.dto'

@Controller('promo')
export class PromoController {
  constructor(private readonly service: PromoService) {}

  @Post()
  create(@Body() dto: CreatePromoDto) {
    return this.service.create(dto)
  }

  @Get()
  list(@Query('active') active?: string) {
    return this.service.list(active === 'true')
  }

  @Get(':code')
  findByCode(@Param('code') code: string) {
    return this.service.findByCode(code)
  }

  @Post('validate')
  validate(@Body() dto: ApplyPromoDto) {
    return this.service.validate(dto)
  }

  @Post('apply')
  apply(@Body() dto: ApplyPromoDto, @Body('referenceId') referenceId?: string) {
    return this.service.apply(dto, referenceId)
  }

  @Put(':id/deactivate')
  deactivate(@Param('id') id: string) {
    return this.service.deactivate(id)
  }
}
