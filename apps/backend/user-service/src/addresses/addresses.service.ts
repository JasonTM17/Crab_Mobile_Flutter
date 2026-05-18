import { Injectable, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { AddressEntity } from './entities/address.entity'
import { CreateAddressDto, UpdateAddressDto } from './dto/address.dto'

@Injectable()
export class AddressesService {
  constructor(
    @InjectRepository(AddressEntity)
    private readonly repo: Repository<AddressEntity>,
  ) {}

  async create(userId: string, dto: CreateAddressDto): Promise<AddressEntity> {
    if (dto.isDefault) {
      await this.repo.update({ userId }, { isDefault: false })
    }
    const addr = this.repo.create({ ...dto, userId })
    return this.repo.save(addr)
  }

  async findByUser(userId: string): Promise<AddressEntity[]> {
    return this.repo.find({
      where: { userId },
      order: { isDefault: 'DESC', createdAt: 'DESC' },
    })
  }

  async findById(id: string, userId: string): Promise<AddressEntity> {
    const addr = await this.repo.findOne({ where: { id, userId } })
    if (!addr) throw new NotFoundException(`Address ${id} not found`)
    return addr
  }

  async update(id: string, userId: string, dto: UpdateAddressDto): Promise<AddressEntity> {
    await this.findById(id, userId)
    if (dto.isDefault) {
      await this.repo.update({ userId }, { isDefault: false })
    }
    await this.repo.update(id, dto)
    return this.findById(id, userId)
  }

  async delete(id: string, userId: string): Promise<void> {
    await this.findById(id, userId)
    await this.repo.delete(id)
  }
}
