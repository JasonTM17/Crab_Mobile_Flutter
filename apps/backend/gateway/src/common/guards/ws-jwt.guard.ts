import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { ConfigService } from '@nestjs/config'
import { WsException } from '@nestjs/websockets'
import { Socket } from 'socket.io'
import { JwtPayload } from '@crab/common-types'

@Injectable()
export class WsJwtGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    const client: Socket = context.switchToWs().getClient()
    const token =
      (client.handshake.auth['token'] as string | undefined) ??
      (client.handshake.headers['authorization'] as string | undefined)
        ?.replace('Bearer ', '')

    if (!token) {
      throw new WsException('Missing authentication token')
    }

    try {
      const payload = this.jwtService.verify<JwtPayload>(token, {
        secret: this.config.get<string>('JWT_SECRET', 'change-me-in-production'),
      })
      client.data['user'] = payload
      return true
    } catch {
      throw new WsException('Invalid or expired token')
    }
  }
}
