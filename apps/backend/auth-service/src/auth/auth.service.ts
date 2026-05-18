import {
  Injectable,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { JwtService } from '@nestjs/jwt'
import { ConfigService } from '@nestjs/config'
import * as bcrypt from 'bcrypt'
import { UserRole, UserStatus, JwtPayload } from '@crab/common-types'
import { UserEntity } from './entities/user.entity'
import { RefreshTokenEntity } from './entities/refresh-token.entity'
import { RegisterDto } from './dto/register.dto'
import { LoginDto } from './dto/login.dto'

const BCRYPT_ROUNDS = 12
const REFRESH_TOKEN_TTL_DAYS = 7

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(RefreshTokenEntity)
    private readonly refreshTokenRepo: Repository<RefreshTokenEntity>,
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {}

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
      status: UserStatus.ACTIVE,
    })
    await this.userRepo.save(user)

    const tokens = await this.generateTokens(user)
    return { user: this.sanitize(user), tokens }
  }

  async login(dto: LoginDto) {
    const user = await this.userRepo.findOne({ where: { email: dto.email } })
    if (!user) {
      throw new UnauthorizedException('Invalid credentials')
    }

    const valid = await bcrypt.compare(dto.password, user.passwordHash)
    if (!valid) {
      throw new UnauthorizedException('Invalid credentials')
    }

    const tokens = await this.generateTokens(user)
    return { user: this.sanitize(user), tokens }
  }

  async refresh(rawToken: string) {
    const record = await this.refreshTokenRepo.findOne({
      where: { token: rawToken, revoked: false },
      relations: ['user'],
    })

    if (!record || record.expiresAt < new Date()) {
      throw new UnauthorizedException('Invalid or expired refresh token')
    }

    // Rotate: revoke old token
    record.revoked = true
    await this.refreshTokenRepo.save(record)

    const tokens = await this.generateTokens(record.user)
    return { user: this.sanitize(record.user), tokens }
  }

  async logout(rawToken: string) {
    await this.refreshTokenRepo.update({ token: rawToken }, { revoked: true })
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  private async generateTokens(user: UserEntity) {
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    }

    const access_token = this.jwtService.sign(payload)

    const refreshSecret = this.config.get<string>('JWT_REFRESH_SECRET', 'refresh-secret')
    const refresh_token = this.jwtService.sign(payload, {
      secret: refreshSecret,
      expiresIn: `${REFRESH_TOKEN_TTL_DAYS}d`,
    })

    const expiresAt = new Date()
    expiresAt.setDate(expiresAt.getDate() + REFRESH_TOKEN_TTL_DAYS)

    const tokenRecord = this.refreshTokenRepo.create({
      token: refresh_token,
      userId: user.id,
      expiresAt,
    })
    await this.refreshTokenRepo.save(tokenRecord)

    return { access_token, refresh_token }
  }

  private sanitize(user: UserEntity) {
    const { passwordHash: _pw, refreshTokens: _rt, ...safe } = user
    return safe
  }
}
