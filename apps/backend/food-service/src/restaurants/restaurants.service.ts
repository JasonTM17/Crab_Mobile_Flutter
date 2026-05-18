import { Injectable, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, Like, FindOptionsWhere } from 'typeorm'
import { RestaurantEntity } from './entities/restaurant.entity'
import {
  CreateRestaurantDto,
  UpdateRestaurantDto,
  SearchRestaurantsDto,
} from './dto/restaurant.dto'

const EARTH_RADIUS_KM = 6371

@Injectable()
export class RestaurantsService {
  constructor(
    @InjectRepository(RestaurantEntity)
    private readonly repo: Repository<RestaurantEntity>,
  ) {}

  async create(dto: CreateRestaurantDto): Promise<RestaurantEntity> {
    const r = this.repo.create(dto)
    return this.repo.save(r)
  }

  async findById(id: string): Promise<RestaurantEntity> {
    const r = await this.repo.findOne({ where: { id } })
    if (!r) throw new NotFoundException(`Restaurant ${id} not found`)
    return r
  }

  async findByMerchant(merchantId: string): Promise<RestaurantEntity[]> {
    return this.repo.find({ where: { merchantId }, order: { createdAt: 'DESC' } })
  }

  async update(id: string, dto: UpdateRestaurantDto): Promise<RestaurantEntity> {
    await this.findById(id)
    await this.repo.update(id, dto as Partial<RestaurantEntity>)
    return this.findById(id)
  }

  async delete(id: string): Promise<void> {
    await this.repo.delete(id)
  }

  async search(dto: SearchRestaurantsDto) {
    const page = dto.page ?? 1
    const limit = dto.limit ?? 20
    const where: FindOptionsWhere<RestaurantEntity> = {}
    if (dto.cuisineType) where.cuisineType = dto.cuisineType
    if (dto.query) where.name = Like(`%${dto.query}%`)

    const all = await this.repo.find({ where, order: { rating: 'DESC' } })

    let filtered = all
    if (dto.latitude !== undefined && dto.longitude !== undefined) {
      const radius = dto.radiusKm ?? 5
      filtered = all
        .map((r) => ({
          ...r,
          distance_km: this.haversine(
            dto.latitude!,
            dto.longitude!,
            Number(r.latitude),
            Number(r.longitude),
          ),
        }))
        .filter((r) => r.distance_km <= radius)
        .sort((a, b) => a.distance_km - b.distance_km)
    }

    const start = (page - 1) * limit
    const data = filtered.slice(start, start + limit)
    return { data, total: filtered.length, page, limit }
  }

  async findFeatured(limit = 10) {
    return this.repo.find({
      where: { isFeatured: true, isOpen: true },
      take: limit,
      order: { rating: 'DESC' },
    })
  }

  async toggleOpen(id: string, isOpen: boolean) {
    await this.repo.update(id, { isOpen })
    return this.findById(id)
  }

  async updateRating(id: string, newRating: number, totalReviews: number) {
    await this.repo.update(id, { rating: newRating, totalReviews })
  }

  private haversine(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const toRad = (deg: number) => (deg * Math.PI) / 180
    const dLat = toRad(lat2 - lat1)
    const dLng = toRad(lng2 - lng1)
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2
    return EARTH_RADIUS_KM * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  }
}
