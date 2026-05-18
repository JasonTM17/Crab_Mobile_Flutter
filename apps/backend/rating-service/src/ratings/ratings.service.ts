import { Injectable, ConflictException, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { DataSource, Repository } from 'typeorm'
import { RatingEntity, RatingTargetType } from './entities/rating.entity'
import { RatingAggregateEntity } from './entities/rating-aggregate.entity'
import { CreateRatingDto, FlagRatingDto } from './dto/rating.dto'

type CountKey = 'count1' | 'count2' | 'count3' | 'count4' | 'count5'

@Injectable()
export class RatingsService {
  constructor(
    @InjectRepository(RatingEntity)
    private readonly ratingRepo: Repository<RatingEntity>,
    @InjectRepository(RatingAggregateEntity)
    private readonly aggRepo: Repository<RatingAggregateEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async create(dto: CreateRatingDto): Promise<RatingEntity> {
    const existing = await this.ratingRepo.findOne({
      where: { referenceId: dto.referenceId, raterId: dto.raterId },
    })
    if (existing) throw new ConflictException('Already rated')

    return this.dataSource.transaction(async (manager) => {
      const rating = manager.create(RatingEntity, dto)
      const saved = await manager.save(rating)

      let agg = await manager.findOne(RatingAggregateEntity, {
        where: { targetId: dto.targetId, targetType: dto.targetType },
      })
      if (!agg) {
        agg = manager.create(RatingAggregateEntity, {
          targetId: dto.targetId,
          targetType: dto.targetType,
          avgScore: dto.score,
          totalRatings: 1,
        })
        const key = `count${dto.score}` as CountKey
        agg[key] = 1
        await manager.save(agg)
      } else {
        const newTotal = agg.totalRatings + 1
        const newSum = Number(agg.avgScore) * agg.totalRatings + dto.score
        agg.avgScore = +(newSum / newTotal).toFixed(2)
        agg.totalRatings = newTotal
        const key = `count${dto.score}` as CountKey
        agg[key] = (agg[key] ?? 0) + 1
        await manager.save(agg)
      }

      return saved
    })
  }

  async findById(id: string): Promise<RatingEntity> {
    const r = await this.ratingRepo.findOne({ where: { id } })
    if (!r) throw new NotFoundException(`Rating ${id} not found`)
    return r
  }

  async listForTarget(
    targetId: string,
    targetType: RatingTargetType,
    page = 1,
    limit = 20,
    minScore?: number,
  ) {
    const qb = this.ratingRepo
      .createQueryBuilder('r')
      .where('r.targetId = :targetId', { targetId })
      .andWhere('r.targetType = :targetType', { targetType })
      .andWhere('r.hidden = false')
    if (minScore) qb.andWhere('r.score >= :minScore', { minScore })

    const [data, total] = await qb
      .skip((page - 1) * limit)
      .take(limit)
      .orderBy('r.createdAt', 'DESC')
      .getManyAndCount()

    return { data, total, page, limit }
  }

  async getAggregate(targetId: string, targetType: RatingTargetType) {
    const agg = await this.aggRepo.findOne({ where: { targetId, targetType } })
    if (!agg) {
      return {
        targetId,
        targetType,
        avgScore: 0,
        totalRatings: 0,
        distribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
      }
    }
    return {
      targetId: agg.targetId,
      targetType: agg.targetType,
      avgScore: Number(agg.avgScore),
      totalRatings: agg.totalRatings,
      distribution: {
        1: agg.count1,
        2: agg.count2,
        3: agg.count3,
        4: agg.count4,
        5: agg.count5,
      },
    }
  }

  async flag(id: string, dto: FlagRatingDto) {
    await this.ratingRepo.update(id, { flagged: true, flagReason: dto.reason })
    return this.findById(id)
  }

  async hide(id: string) {
    await this.ratingRepo.update(id, { hidden: true })
    return this.findById(id)
  }

  async findByReference(referenceId: string) {
    return this.ratingRepo.find({ where: { referenceId } })
  }

  async findByRater(raterId: string, limit = 50) {
    return this.ratingRepo.find({
      where: { raterId },
      order: { createdAt: 'DESC' },
      take: limit,
    })
  }
}
