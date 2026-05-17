import { Injectable, BadRequestException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm'
import { PromoCodeEntity } from './entities/promo-code.entity'

export interface PromoResult {
  valid: boolean
  discount_amount: number
  message: string
}

@Injectable()
export class PromoService {
  constructor(
    @InjectRepository(PromoCodeEntity)
    private readonly promoRepo: Repository<PromoCodeEntity>,
  ) {}

  async validate(code: string, orderAmount: number): Promise<PromoResult> {
    const promo = await this.promoRepo.findOneBy({ code, is_active: true })
    if (!promo) return { valid: false, discount_amount: 0, message: 'Invalid promo code' }

    const now = new Date()
    if (now < promo.valid_from || now > promo.valid_until) {
      return { valid: false, discount_amount: 0, message: 'Promo code expired' }
    }
    if (promo.current_uses >= promo.max_uses) {
      return { valid: false, discount_amount: 0, message: 'Promo code fully redeemed' }
    }
    if (orderAmount < Number(promo.min_order_amount)) {
      return { valid: false, discount_amount: 0, message: `Minimum order: ${promo.min_order_amount} VND` }
    }

    let discount = orderAmount * (Number(promo.discount_percent) / 100)
    if (promo.max_discount && discount > Number(promo.max_discount)) {
      discount = Number(promo.max_discount)
    }

    return { valid: true, discount_amount: Math.round(discount), message: 'Promo applied' }
  }

  async redeem(code: string): Promise<void> {
    await this.promoRepo.increment({ code }, 'current_uses', 1)
  }

  async create(data: Partial<PromoCodeEntity>) {
    const promo = this.promoRepo.create(data)
    return this.promoRepo.save(promo)
  }
}
