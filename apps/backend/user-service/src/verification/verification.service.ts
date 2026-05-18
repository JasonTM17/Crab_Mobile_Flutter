import { Injectable, NotFoundException, ConflictException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import {
  DriverProfileEntity,
  DriverVerificationStatus,
} from './entities/driver-profile.entity'
import {
  MerchantProfileEntity,
  MerchantVerificationStatus,
} from './entities/merchant-profile.entity'
import { VerificationDocEntity, DocType } from './entities/verification-doc.entity'
import { RegisterDriverDto } from './dto/driver.dto'
import { RegisterMerchantDto } from './dto/merchant.dto'

@Injectable()
export class VerificationService {
  constructor(
    @InjectRepository(DriverProfileEntity)
    private readonly driverRepo: Repository<DriverProfileEntity>,
    @InjectRepository(MerchantProfileEntity)
    private readonly merchantRepo: Repository<MerchantProfileEntity>,
    @InjectRepository(VerificationDocEntity)
    private readonly docRepo: Repository<VerificationDocEntity>,
  ) {}

  async registerDriver(userId: string, dto: RegisterDriverDto) {
    const existing = await this.driverRepo.findOne({ where: { userId } })
    if (existing) throw new ConflictException('Driver profile already exists')
    const profile = this.driverRepo.create({
      userId,
      ...dto,
      licenseExpiry: new Date(dto.licenseExpiry),
      insuranceExpiry: dto.insuranceExpiry ? new Date(dto.insuranceExpiry) : undefined,
    })
    return this.driverRepo.save(profile)
  }

  async getDriverProfile(userId: string) {
    const profile = await this.driverRepo.findOne({ where: { userId } })
    if (!profile) throw new NotFoundException('Driver profile not found')
    return profile
  }

  async approveDriver(userId: string) {
    await this.driverRepo.update(userId, {
      verificationStatus: DriverVerificationStatus.APPROVED,
      rejectionReason: undefined,
    })
    return this.getDriverProfile(userId)
  }

  async rejectDriver(userId: string, reason: string) {
    await this.driverRepo.update(userId, {
      verificationStatus: DriverVerificationStatus.REJECTED,
      rejectionReason: reason,
    })
    return this.getDriverProfile(userId)
  }

  async setDriverOnline(userId: string, isOnline: boolean) {
    const driver = await this.getDriverProfile(userId)
    if (driver.verificationStatus !== DriverVerificationStatus.APPROVED) {
      throw new ConflictException('Driver not approved')
    }
    await this.driverRepo.update(userId, { isOnline })
    return this.getDriverProfile(userId)
  }

  async listPendingDrivers(page = 1, limit = 20) {
    const [data, total] = await this.driverRepo.findAndCount({
      where: { verificationStatus: DriverVerificationStatus.PENDING },
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'ASC' },
    })
    return { data, total, page, limit }
  }

  async registerMerchant(userId: string, dto: RegisterMerchantDto) {
    const existing = await this.merchantRepo.findOne({ where: { userId } })
    if (existing) throw new ConflictException('Merchant profile already exists')
    const profile = this.merchantRepo.create({ userId, ...dto })
    return this.merchantRepo.save(profile)
  }

  async getMerchantProfile(userId: string) {
    const profile = await this.merchantRepo.findOne({ where: { userId } })
    if (!profile) throw new NotFoundException('Merchant profile not found')
    return profile
  }

  async approveMerchant(userId: string) {
    await this.merchantRepo.update(userId, {
      verificationStatus: MerchantVerificationStatus.APPROVED,
    })
    return this.getMerchantProfile(userId)
  }

  async rejectMerchant(userId: string, reason: string) {
    await this.merchantRepo.update(userId, {
      verificationStatus: MerchantVerificationStatus.REJECTED,
      rejectionReason: reason,
    })
    return this.getMerchantProfile(userId)
  }

  async uploadDocument(userId: string, docType: DocType, fileUrl: string) {
    const existing = await this.docRepo.findOne({ where: { userId, docType } })
    if (existing) {
      existing.fileUrl = fileUrl
      existing.verified = false
      existing.verifiedAt = undefined
      existing.verifiedBy = undefined
      return this.docRepo.save(existing)
    }
    const doc = this.docRepo.create({ userId, docType, fileUrl })
    return this.docRepo.save(doc)
  }

  async getUserDocuments(userId: string) {
    return this.docRepo.find({ where: { userId }, order: { uploadedAt: 'DESC' } })
  }

  async verifyDocument(docId: string, adminId: string) {
    await this.docRepo.update(docId, {
      verified: true,
      verifiedBy: adminId,
      verifiedAt: new Date(),
    })
  }
}
