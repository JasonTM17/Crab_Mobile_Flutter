import { Controller, Get, Post, Body, Query, HttpStatus } from '@nestjs/common'
import { PromoService } from './promo.service'

@Controller('promo')
export class PromoController {
  constructor(private readonly promoService: PromoService) {}

  @Post('validate')
  async validate(@Body() body: { code: string; order_amount: number }) {
    const result = await this.promoService.validate(body.code, body.order_amount)
    return { success: true, data: result, statusCode: HttpStatus.OK }
  }

  @Post()
  async create(@Body() body: any) {
    const promo = await this.promoService.create(body)
    return { success: true, data: promo, statusCode: HttpStatus.CREATED }
  }
}
