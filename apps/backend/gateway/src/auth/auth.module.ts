import { Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { ConfigModule } from '@nestjs/config'
import { JwtAuthStrategy } from './jwt.strategy'
import { JwtAuthGuard } from './jwt-auth.guard'

@Module({
  imports: [ConfigModule, PassportModule, JwtModule],
  providers: [JwtAuthStrategy, JwtAuthGuard],
  exports: [JwtAuthStrategy, JwtAuthGuard],
})
export class AuthModule {}
