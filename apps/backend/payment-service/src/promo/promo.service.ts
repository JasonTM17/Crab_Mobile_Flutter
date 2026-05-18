import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, DataSource, MoreThan } from 'typeorm'
import {
  PromoEntity,
  PromoUsageEntity,
  PromoType,
  PromoApplicableTo,
} from './entities/promo.entity'
import { CreatePromoDto, ApplyPromoDto } from './dto/promo.dto'

export interface PromoApplyResult {
  promo: PromoEntity
  discountAmount: number
  finalAmount: number
}

@Injectable()
export class PromoService {
  constructor(
    @InjectRepository(PromoEntity)
    private readonly promoRepo: Repository<PromoEntity>,
    @InjectRepository(PromoUsageEntity)
    private readonly usageRepo: Repository<PromoUsageEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async create(dto: CreatePromoDto): Promise<PromoEntity> {
    const existing = await this.promoRepo.findOne({ where: { code: dto.code } })
    if (existing) throw new BadRequestException('Code already exists')
    const promo = this.promoRepo.create({
      ...dto,
      validFrom: new Date(dto.validFrom),
      validUntil: new Date(dto.validUntil),
    })
    return this.promoRepo.save(promo)
  }

  async list(activeOnly = false) {
    const where = activeOnly
      ? { isActive: true, validUntil: MoreThan(new Date()) }
      : {}
    return this.promoRepo.find({
      where,
      order: { createdAt: 'DESC' },
    })
  }

  async findByCode(code: string): Promise<PromoEntity> {
    const promo = await this.promoRepo.findOne({ where: { code } })
    if (!promo) throw new NotFoundException(`Promo ${code} not found`)
    return promo
  }

  async validate(dto: ApplyPromoDto): Promise<PromoApplyResult> {
    const promo = await this.findByCode(dto.code)

    if (!promo.isActive) {
      throw new BadRequestException('Promo not active')
    }
    const now = new Date()
    if (promo.validFrom > now || promo.validUntil < now) {
      throw new BadRequestException('Promo not in valid period')
    }
    if (dto.orderValue < Number(promo.minOrderValue)) {
      throw new BadRequestException(
        `Minimum order value: ${promo.minOrderValue}`,
      )
    }
    if (
      dto.context &&
      promo.applicableTo !== PromoApplicableTo.ALL &&
      promo.applicableTo !== dto.context
    ) {
      throw new BadRequestException('Promo not applicable to this context')
    }

    const userUsageCount = await this.usageRepo.count({
      where: { userId: dto.userId, promoId: promo.id },
    })
    if (userUsageCount >= promo.usageLimitPerUser) {
      throw new BadRequestException('Promo already used')
    }
    if (promo.totalUsageLimit && promo.totalUsed >= promo.totalUsageLimit) {
      throw new BadRequestException('Promo usage limit exceeded')
    }

    let discountAmount = 0
    if (promo.type === PromoType.PERCENTAGE) {
      discountAmount = (dto.orderValue * Number(promo.value)) / 100
      if (promo.maxDiscount) {
        discountAmount = Math.min(discountAmount, Number(promo.maxDiscount))
      }
    } else if (promo.type === PromoType.FIXED) {
      discountAmount = Math.min(Number(promo.value), dto.orderValue)
    } else if (promo.type === PromoType.FREE_RIDE) {
      discountAmount = dto.orderValue
    }

    return {
      promo,
      discountAmount: Math.round(discountAmount),
      finalAmount: Math.max(0, dto.orderValue - Math.round(discountAmount)),
    }
  }

  async apply(
    dto: ApplyPromoDto,
    referenceId?: string,
  ): Promise<PromoApplyResult> {
    return this.dataSource.transaction(async (manager) => {
      const result = await this.validate(dto)
      await manager.increment(PromoEntity, { id: result.promo.id }, 'totalUsed', 1)
      const usage = manager.create(PromoUsageEntity, {
        userId: dto.userId,
        promoId: result.promo.id,
        referenceId,
        discountAmount: result.discountAmount,
      })
      await manager.save(usage)
      return result
    })
  }

  async deactivate(id: string) {
    await this.promoRepo.update(id, { isActive: false })
    return this.promoRepo.findOne({ where: { id } })
  }
}
