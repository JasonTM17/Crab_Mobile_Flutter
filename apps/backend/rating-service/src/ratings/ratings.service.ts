import { Injectable, ConflictException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { Rating } from './entities/rating.entity'
import { CreateRatingDto } from './dto/create-rating.dto'

@Injectable()
export class RatingsService {
  constructor(
    @InjectRepository(Rating)
    private readonly ratingRepo: Repository<Rating>,
  ) {}

  async create(userId: string, dto: CreateRatingDto): Promise<Rating> {
    const existing = await this.ratingRepo.findOne({
      where: {
        userId,
        targetType: dto.targetType,
        targetId: dto.targetId,
      },
    })

    if (existing) {
      existing.score = dto.score
      return this.ratingRepo.save(existing)
    }

    const rating = this.ratingRepo.create({
      userId,
      ...dto,
    })
    return this.ratingRepo.save(rating)
  }

  async getAverageRating(
    targetType: string,
    targetId: string,
  ): Promise<{ average: number; count: number }> {
    const result = await this.ratingRepo
      .createQueryBuilder('rating')
      .select('AVG(rating.score)', 'average')
      .addSelect('COUNT(*)', 'count')
      .where('rating.targetType = :targetType', { targetType })
      .andWhere('rating.targetId = :targetId', { targetId })
      .getRawOne()

    return {
      average: parseFloat(result.average) || 0,
      count: parseInt(result.count) || 0,
    }
  }

  async getUserRatings(userId: string): Promise<Rating[]> {
    return this.ratingRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    })
  }

  async getTargetRatings(
    targetType: string,
    targetId: string,
    page = 1,
    limit = 20,
  ): Promise<Rating[]> {
    return this.ratingRepo.find({
      where: { targetType, targetId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    })
  }
}
