import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { UserEntity } from './entities/user.entity'
import { UpdateProfileDto } from './dto/update-profile.dto'
import { MinioService } from './minio.service'

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    private readonly minioService: MinioService,
  ) {}

  async getProfile(id: string): Promise<UserEntity> {
    const user = await this.userRepo.findOne({ where: { id } })
    if (!user) {
      throw new NotFoundException(`User ${id} not found`)
    }
    return user
  }

  async updateProfile(
    id: string,
    requesterId: string,
    dto: UpdateProfileDto,
  ): Promise<UserEntity> {
    if (id !== requesterId) {
      throw new ForbiddenException('Cannot update another user\'s profile')
    }

    const user = await this.getProfile(id)
    Object.assign(user, dto)
    return this.userRepo.save(user)
  }

  async uploadAvatar(
    id: string,
    requesterId: string,
    buffer: Buffer,
    mimeType: string,
  ): Promise<{ avatarUrl: string }> {
    if (id !== requesterId) {
      throw new ForbiddenException('Cannot update another user\'s avatar')
    }

    const user = await this.getProfile(id)

    // Delete old avatar if exists
    if (user.avatarUrl) {
      await this.minioService.deleteObject(user.avatarUrl)
    }

    const avatarUrl = await this.minioService.uploadAvatar(id, buffer, mimeType)
    user.avatarUrl = avatarUrl
    await this.userRepo.save(user)

    return { avatarUrl }
  }
}
