import { Injectable, Logger } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { DeviceEntity } from '../entities/device.entity'
import { RegisterDeviceDto } from '../dto/device.dto'

const MAX_DEVICES_PER_USER = 5

@Injectable()
export class DeviceService {
  private readonly logger = new Logger(DeviceService.name)

  constructor(
    @InjectRepository(DeviceEntity)
    private readonly deviceRepo: Repository<DeviceEntity>,
  ) {}

  async registerDevice(
    userId: string,
    dto: RegisterDeviceDto,
    ip?: string,
  ): Promise<DeviceEntity> {
    // Check if device already registered
    let device = await this.deviceRepo.findOne({
      where: { userId, deviceId: dto.deviceId },
    })

    if (device) {
      // Update existing device
      device.deviceName = dto.deviceName ?? device.deviceName
      device.platform = dto.platform ?? device.platform
      device.fcmToken = dto.fcmToken ?? device.fcmToken
      device.lastIp = ip ?? device.lastIp
      device.lastActiveAt = new Date()
      device.isActive = true
      return this.deviceRepo.save(device)
    }

    // Check max devices limit
    const count = await this.deviceRepo.count({ where: { userId, isActive: true } })
    if (count >= MAX_DEVICES_PER_USER) {
      // Deactivate oldest device
      const oldest = await this.deviceRepo.findOne({
        where: { userId, isActive: true },
        order: { lastActiveAt: 'ASC' },
      })
      if (oldest) {
        oldest.isActive = false
        await this.deviceRepo.save(oldest)
      }
    }

    // Create new device
    device = this.deviceRepo.create({
      userId,
      deviceId: dto.deviceId,
      deviceName: dto.deviceName,
      platform: dto.platform,
      fcmToken: dto.fcmToken,
      lastIp: ip,
      lastActiveAt: new Date(),
    })

    this.logger.log(`Device registered for user ${userId}: ${dto.deviceId}`)
    return this.deviceRepo.save(device)
  }

  async getUserDevices(userId: string): Promise<DeviceEntity[]> {
    return this.deviceRepo.find({
      where: { userId, isActive: true },
      order: { lastActiveAt: 'DESC' },
    })
  }

  async deactivateDevice(userId: string, deviceId: string): Promise<void> {
    await this.deviceRepo.update(
      { userId, deviceId },
      { isActive: false },
    )
  }

  async updateFcmToken(userId: string, deviceId: string, fcmToken: string): Promise<void> {
    await this.deviceRepo.update(
      { userId, deviceId },
      { fcmToken, lastActiveAt: new Date() },
    )
  }

  async deactivateAllDevices(userId: string): Promise<void> {
    await this.deviceRepo.update({ userId }, { isActive: false })
  }
}
