import { Injectable, UnauthorizedException, Logger } from '@nestjs/common'
import { PassportStrategy } from '@nestjs/passport'
import { ExtractJwt, Strategy } from 'passport-jwt'
import { ConfigService } from '@nestjs/config'
import { JwtPayload } from '@crab/common-types'

@Injectable()
export class JwtAuthStrategy extends PassportStrategy(Strategy) {
  constructor(config: ConfigService) {
    const secret = config.get<string>('JWT_SECRET')
    if (!secret || secret === 'change-me-in-production') {
      const logger = new Logger('JwtAuthStrategy')
      if (config.get<string>('NODE_ENV') === 'production') {
        throw new Error('JWT_SECRET must be set to a strong value in production')
      }
      logger.warn('JWT_SECRET is using a development default — DO NOT use in production')
    }
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: secret ?? 'dev-only-fallback-secret',
    })
  }

  async validate(payload: JwtPayload): Promise<JwtPayload> {
    if (!payload.sub) {
      throw new UnauthorizedException('Invalid token payload')
    }
    return payload
  }
}
