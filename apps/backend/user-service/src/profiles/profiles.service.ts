import { Injectable, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { ProfileEntity } from './entities/profile.entity'
import { CreateProfileDto, UpdateProfileDto } from './dto/update-profile.dto'

@Injectable()
export class ProfilesService {
  constructor(
    @InjectRepository(ProfileEntity)
    private readonly repo: Repository<ProfileEntity>,
  ) {}

  async create(dto: CreateProfileDto): Promise<ProfileEntity> {
    const profile = this.repo.create(dto)
    return this.repo.save(profile)
  }

  async findById(userId: string): Promise<ProfileEntity> {
    const profile = await this.repo.findOne({ where: { userId } })
    if (!profile) throw new NotFoundException(`Profile ${userId} not found`)
    return profile
  }

  async update(userId: string, dto: UpdateProfileDto): Promise<ProfileEntity> {
    await this.findById(userId)
    await this.repo.update(userId, dto as Partial<ProfileEntity>)
    return this.findById(userId)
  }

  async delete(userId: string): Promise<void> {
    await this.repo.delete(userId)
  }

  async list(page = 1, limit = 20) {
    const [data, total] = await this.repo.findAndCount({
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    })
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }
}
