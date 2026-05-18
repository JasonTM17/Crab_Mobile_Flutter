import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { ConfigModule } from '@nestjs/config'
import { AuthController } from './auth.controller'
import { AuthService } from './auth.service'
import { JwtStrategy } from './strategies/jwt.strategy'
import { OtpService } from './services/otp.service'
import { SessionService } from './services/session.service'
import { DeviceService } from './services/device.service'
import { UserEntity } from './entities/user.entity'
import { RefreshTokenEntity } from './entities/refresh-token.entity'
import { OtpEntity } from './entities/otp.entity'
import { DeviceEntity } from './entities/device.entity'
import { LoginAttemptEntity } from './entities/login-attempt.entity'

@Module({
  imports: [
    ConfigModule,
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule,
    TypeOrmModule.forFeature([
      UserEntity,
      RefreshTokenEntity,
      OtpEntity,
      DeviceEntity,
      LoginAttemptEntity,
    ]),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, OtpService, SessionService, DeviceService],
  exports: [AuthService, JwtStrategy, SessionService],
})
export class AuthModule {}
