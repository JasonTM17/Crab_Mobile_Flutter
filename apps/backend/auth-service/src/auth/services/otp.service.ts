import { Injectable, Logger, BadRequestException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, MoreThan } from 'typeorm'
import { OtpEntity, OtpPurpose } from '../entities/otp.entity'

const OTP_EXPIRY_MINUTES = 5
const MAX_OTP_ATTEMPTS = 5
const OTP_COOLDOWN_SECONDS = 60

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name)

  constructor(
    @InjectRepository(OtpEntity)
    private readonly otpRepo: Repository<OtpEntity>,
  ) {}

  async generate(phone: string, purpose: OtpPurpose): Promise<string> {
    // Check cooldown - prevent spam
    const recent = await this.otpRepo.findOne({
      where: {
        phone,
        purpose,
        createdAt: MoreThan(new Date(Date.now() - OTP_COOLDOWN_SECONDS * 1000)),
      },
      order: { createdAt: 'DESC' },
    })

    if (recent) {
      throw new BadRequestException(
        `Please wait ${OTP_COOLDOWN_SECONDS} seconds before requesting a new OTP`,
      )
    }

    // Generate 6-digit code
    const code = Math.floor(100000 + Math.random() * 900000).toString()

    const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000)

    const otp = this.otpRepo.create({
      phone,
      code,
      purpose,
      expiresAt,
    })
    await this.otpRepo.save(otp)

    this.logger.log(`OTP generated for ${phone} (purpose: ${purpose})`)

    // In production, send via SMS provider (Twilio, Firebase, etc.)
    // For dev, log the code
    if (process.env.NODE_ENV !== 'production') {
      this.logger.debug(`[DEV] OTP for ${phone}: ${code}`)
    }

    return code
  }

  async verify(phone: string, code: string, purpose: OtpPurpose): Promise<boolean> {
    const otp = await this.otpRepo.findOne({
      where: {
        phone,
        purpose,
        verified: false,
        expiresAt: MoreThan(new Date()),
      },
      order: { createdAt: 'DESC' },
    })

    if (!otp) {
      throw new BadRequestException('OTP expired or not found')
    }

    if (otp.attempts >= MAX_OTP_ATTEMPTS) {
      throw new BadRequestException('Too many attempts. Please request a new OTP')
    }

    otp.attempts += 1

    if (otp.code !== code) {
      await this.otpRepo.save(otp)
      throw new BadRequestException(
        `Invalid OTP. ${MAX_OTP_ATTEMPTS - otp.attempts} attempts remaining`,
      )
    }

    otp.verified = true
    await this.otpRepo.save(otp)

    return true
  }

  async cleanup(): Promise<void> {
    // Remove expired OTPs older than 1 hour
    const cutoff = new Date(Date.now() - 60 * 60 * 1000)
    await this.otpRepo
      .createQueryBuilder()
      .delete()
      .where('expiresAt < :cutoff', { cutoff })
      .execute()
  }
}
