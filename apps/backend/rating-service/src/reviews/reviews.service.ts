import { Injectable } from '@nestjs/common'
import { InjectModel } from '@nestjs/mongoose'
import { Model } from 'mongoose'
import { Review } from './schemas/review.schema'

@Injectable()
export class ReviewsService {
  constructor(
    @InjectModel(Review.name) private readonly reviewModel: Model<Review>,
  ) {}

  async create(userId: string, data: Partial<Review>): Promise<Review> {
    const review = new this.reviewModel({ ...data, userId })
    return review.save()
  }

  async findByTarget(
    targetType: string,
    targetId: string,
    page = 1,
    limit = 20,
  ): Promise<{ reviews: Review[]; total: number }> {
    const [reviews, total] = await Promise.all([
      this.reviewModel
        .find({ targetType, targetId, isHidden: false })
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .exec(),
      this.reviewModel.countDocuments({ targetType, targetId, isHidden: false }),
    ])
    return { reviews, total }
  }

  async findByUser(userId: string): Promise<Review[]> {
    return this.reviewModel
      .find({ userId })
      .sort({ createdAt: -1 })
      .exec()
  }

  async reply(reviewId: string, content: string): Promise<Review> {
    return this.reviewModel.findByIdAndUpdate(
      reviewId,
      { replyContent: content, replyAt: new Date() },
      { new: true },
    )
  }

  async getStats(
    targetType: string,
    targetId: string,
  ): Promise<{ average: number; count: number; distribution: Record<number, number> }> {
    const reviews = await this.reviewModel.find({ targetType, targetId, isHidden: false })
    const count = reviews.length
    if (count === 0) return { average: 0, count: 0, distribution: {} }

    const sum = reviews.reduce((acc, r) => acc + r.score, 0)
    const distribution: Record<number, number> = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
    reviews.forEach((r) => {
      distribution[r.score] = (distribution[r.score] || 0) + 1
    })

    return { average: sum / count, count, distribution }
  }
}
