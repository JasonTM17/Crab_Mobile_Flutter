import { Module } from '@nestjs/common'
import { JwtModule } from '@nestjs/jwt'
import { PassportModule } from '@nestjs/passport'
import { ConfigModule } from '@nestjs/config'
import { JwtAuthStrategy } from './jwt.strategy'

@Module({
  imports: [ConfigModule, PassportModule, JwtModule],
  providers: [JwtAuthStrategy],
  exports: [JwtAuthStrategy],
})
export class AuthModule {}
