import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  BadRequestException,
  ForbiddenException,
  Logger,
} from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { JwtService } from '@nestjs/jwt'
import { ConfigService } from '@nestjs/config'
import * as bcrypt from 'bcrypt'
import * as crypto from 'crypto'
import { UserRole, UserStatus, JwtPayload } from '@crab/common-types'
import { UserEntity } from './entities/user.entity'
import { RefreshTokenEntity } from './entities/refresh-token.entity'
import { LoginAttemptEntity } from './entities/login-attempt.entity'
import { OtpService } from './services/otp.service'
import { SessionService } from './services/session.service'
import { getRequiredRefreshSecret } from '../security'
import { OtpPurpose } from './entities/otp.entity'
import { RegisterDto } from './dto/register.dto'
import { LoginDto } from './dto/login.dto'
import { PhoneLoginDto } from './dto/phone-login.dto'
import { VerifyOtpDto } from './dto/verify-otp.dto'
import {
  RequestPasswordResetDto,
  ConfirmPasswordResetDto,
} from './dto/reset-password.dto'
import { ChangePasswordDto } from './dto/change-password.dto'

const BCRYPT_ROUNDS = 12
const REFRESH_TOKEN_TTL_DAYS = 7
const MAX_FAILED_ATTEMPTS = 5
const LOCK_DURATION_MINUTES = 30

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name)

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(RefreshTokenEntity)
    private readonly refreshTokenRepo: Repository<RefreshTokenEntity>,
    @InjectRepository(LoginAttemptEntity)
    private readonly loginAttemptRepo: Repository<LoginAttemptEntity>,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
    private readonly otpService: OtpService,
    private readonly sessionService: SessionService,
  ) {
    getRequiredRefreshSecret(this.config)
  }

  async register(dto: RegisterDto) {
    const existing = await this.userRepo.findOne({
      where: [{ email: dto.email }, { phone: dto.phone }],
    })
    if (existing) {
      throw new ConflictException('Email or phone already registered')
    }

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS)
    const user = this.userRepo.create({
      email: dto.email,
      phone: dto.phone,
      passwordHash,
      firstName: dto.firstName,
      lastName: dto.lastName,
      role: UserRole.RIDER,
      status: UserStatus.PENDING_VERIFICATION,
    })
    await this.userRepo.save(user)

    // Generate OTP for phone verification
    await this.otpService.generate(dto.phone, OtpPurpose.PHONE_VERIFY)

    const tokens = await this.generateTokens(user)
    return { user: this.sanitize(user), tokens, requiresPhoneVerification: true }
  }

  async login(dto: LoginDto, ip?: string, userAgent?: string) {
    await this.checkAccountLock(dto.email)

    const user = await this.userRepo.findOne({ where: { email: dto.email } })
    if (!user) {
      await this.recordLoginAttempt(dto.email, ip ?? 'unknown', false, userAgent)
      throw new UnauthorizedException('Invalid credentials')
    }

    if (user.status === UserStatus.SUSPENDED) {
      throw new ForbiddenException('Account suspended')
    }

    const valid = await bcrypt.compare(dto.password, user.passwordHash)
    if (!valid) {
      await this.handleFailedLogin(user, ip ?? 'unknown', userAgent)
      throw new UnauthorizedException('Invalid credentials')
    }

    // Reset failed attempts on success
    if (user.failedLoginCount > 0) {
      await this.userRepo.update(user.id, {
        failedLoginCount: 0,
        lockedUntil: undefined,
      })
    }
    await this.userRepo.update(user.id, { lastLoginAt: new Date() })
    await this.recordLoginAttempt(dto.email, ip ?? 'unknown', true, userAgent)
    await this.sessionService.resetLoginAttempts(dto.email)

    const tokens = await this.generateTokens(user)
    return { user: this.sanitize(user), tokens }
  }

  async requestPhoneLogin(dto: PhoneLoginDto) {
    const user = await this.userRepo.findOne({ where: { phone: dto.phone } })
    if (!user) {
      // Do not reveal whether phone exists
      return { sent: true, message: 'OTP sent if phone is registered' }
    }
    if (user.status === UserStatus.SUSPENDED) {
      throw new ForbiddenException('Account suspended')
    }
    await this.otpService.generate(dto.phone, OtpPurpose.LOGIN)
    return { sent: true, message: 'OTP sent successfully' }
  }

  async verifyPhoneLogin(dto: VerifyOtpDto, ip?: string, userAgent?: string) {
    await this.otpService.verify(dto.phone, dto.code, OtpPurpose.LOGIN)

    const user = await this.userRepo.findOne({ where: { phone: dto.phone } })
    if (!user) {
      throw new UnauthorizedException('User not found')
    }

    await this.userRepo.update(user.id, {
      phoneVerified: true,
      lastLoginAt: new Date(),
      ...(user.status === UserStatus.PENDING_VERIFICATION
        ? { status: UserStatus.ACTIVE }
        : {}),
    })

    await this.recordLoginAttempt(dto.phone, ip ?? 'unknown', true, userAgent)
    const tokens = await this.generateTokens(user)
    return { user: this.sanitize(user), tokens }
  }

  async verifyPhone(dto: VerifyOtpDto) {
    await this.otpService.verify(dto.phone, dto.code, OtpPurpose.PHONE_VERIFY)
    const user = await this.userRepo.findOne({ where: { phone: dto.phone } })
    if (!user) {
      throw new UnauthorizedException('User not found')
    }
    await this.userRepo.update(user.id, {
      phoneVerified: true,
      status: UserStatus.ACTIVE,
    })
    return { verified: true }
  }

  async requestPasswordReset(dto: RequestPasswordResetDto) {
    const user = await this.userRepo.findOne({ where: { phone: dto.phone } })
    if (user) {
      await this.otpService.generate(dto.phone, OtpPurpose.PASSWORD_RESET)
    }
    return { sent: true, message: 'OTP sent if phone is registered' }
  }

  async confirmPasswordReset(dto: ConfirmPasswordResetDto) {
    await this.otpService.verify(dto.phone, dto.code, OtpPurpose.PASSWORD_RESET)
    const user = await this.userRepo.findOne({ where: { phone: dto.phone } })
    if (!user) {
      throw new UnauthorizedException('User not found')
    }
    const passwordHash = await bcrypt.hash(dto.newPassword, BCRYPT_ROUNDS)
    await this.userRepo.update(user.id, {
      passwordHash,
      failedLoginCount: 0,
      lockedUntil: undefined,
    })
    // Invalidate all sessions
    await this.refreshTokenRepo.update({ userId: user.id }, { revoked: true })
    await this.sessionService.deleteAllUserSessions(user.id)
    return { success: true }
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.userRepo.findOne({ where: { id: userId } })
    if (!user) {
      throw new UnauthorizedException('User not found')
    }
    const valid = await bcrypt.compare(dto.currentPassword, user.passwordHash)
    if (!valid) {
      throw new UnauthorizedException('Current password incorrect')
    }
    const passwordHash = await bcrypt.hash(dto.newPassword, BCRYPT_ROUNDS)
    await this.userRepo.update(userId, { passwordHash })
    return { success: true }
  }

  async refresh(rawToken: string) {
    const tokenHash = this.hashToken(rawToken)
    const record = await this.refreshTokenRepo.findOne({
      where: { token: tokenHash, revoked: false },
      relations: ['user'],
    })

    if (!record || record.expiresAt < new Date()) {
      throw new UnauthorizedException('Invalid or expired refresh token')
    }

    record.revoked = true
    await this.refreshTokenRepo.save(record)

    const tokens = await this.generateTokens(record.user)
    return { user: this.sanitize(record.user), tokens }
  }

  async logout(rawToken: string) {
    const tokenHash = this.hashToken(rawToken)
    await this.refreshTokenRepo.update({ token: tokenHash }, { revoked: true })
  }

  async logoutAll(userId: string) {
    await this.refreshTokenRepo.update({ userId }, { revoked: true })
    await this.sessionService.deleteAllUserSessions(userId)
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  private async checkAccountLock(email: string) {
    const user = await this.userRepo.findOne({ where: { email } })
    if (user?.lockedUntil && user.lockedUntil > new Date()) {
      const minutes = Math.ceil(
        (user.lockedUntil.getTime() - Date.now()) / 60000,
      )
      throw new ForbiddenException(
        `Account locked. Try again in ${minutes} minutes`,
      )
    }
  }

  private async handleFailedLogin(
    user: UserEntity,
    ip: string,
    userAgent?: string,
  ) {
    const newCount = user.failedLoginCount + 1
    const updates: Partial<UserEntity> = { failedLoginCount: newCount }

    if (newCount >= MAX_FAILED_ATTEMPTS) {
      updates.lockedUntil = new Date(Date.now() + LOCK_DURATION_MINUTES * 60000)
      this.logger.warn(`Account locked for user ${user.email}`)
    }

    await this.userRepo.update(user.id, updates)
    await this.recordLoginAttempt(user.email, ip, false, userAgent)
  }

  private async recordLoginAttempt(
    identifier: string,
    ip: string,
    success: boolean,
    userAgent?: string,
  ) {
    const attempt = this.loginAttemptRepo.create({
      identifier,
      ip,
      success,
      userAgent,
    })
    await this.loginAttemptRepo.save(attempt)
  }

  private async generateTokens(user: UserEntity) {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    }

    const access_token = this.jwtService.sign(payload)

    const refreshSecret = getRequiredRefreshSecret(this.config)
    const refresh_token = this.jwtService.sign(payload, {
      secret: refreshSecret,
      expiresIn: `${REFRESH_TOKEN_TTL_DAYS}d`,
    })

    const expiresAt = new Date()
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_TTL_DAYS)

    const tokenRecord = this.refreshTokenRepo.create({
      token: this.hashToken(refresh_token),
      userId: user.id,
      expiresAt,
    })
    await this.refreshTokenRepo.save(tokenRecord)

    return { access_token, refresh_token }
  }

  private hashToken(token: string): string {
    // Fast deterministic hash for token lookup. SHA-256 is sufficient since
    // refresh tokens are already high-entropy JWTs; bcrypt would be too slow
    // for the per-request lookup pattern.
    return crypto.createHash('sha256').update(token).digest('hex')
  }

  private sanitize(user: UserEntity) {
    const { passwordHash: _pw, refreshTokens: _rt, ...safe } = user
    return safe
  }
}
