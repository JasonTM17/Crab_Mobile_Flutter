import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import { Reflector } from '@nestjs/core'
import { IS_PUBLIC_KEY } from './public.decorator'

/**
 * JwtAuthGuard checks @Public() metadata first; otherwise validates the
 * Authorization Bearer token via the jwt passport strategy.
 *
 * After successful validation it copies the JWT payload onto request headers
 * so downstream microservices can trust X-User-Id and X-User-Role without
 * re-validating the JWT (gateway is source of truth).
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private readonly reflector: Reflector) {
    super()
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ])
    if (isPublic) return true
    return super.canActivate(context)
  }

  handleRequest<TUser = { sub: string; role?: string; email?: string }>(
    err: unknown,
    user: TUser,
    info: unknown,
    context: ExecutionContext,
  ): TUser {
    if (err || !user) {
      throw new UnauthorizedException(
        (err as Error)?.message || (info as Error)?.message || 'Unauthorized',
      )
    }
    const req = context.switchToHttp().getRequest()
    const u = user as unknown as {
      sub?: string
      role?: string
      email?: string
    }
    if (u.sub) {
      req.headers['x-user-id'] = u.sub
      if (u.role) req.headers['x-user-role'] = u.role
      if (u.email) req.headers['x-user-email'] = u.email
    }
    return user
  }
}
