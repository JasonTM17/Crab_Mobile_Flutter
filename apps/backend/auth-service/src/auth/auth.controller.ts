import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
  Req,
  Get,
} from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import type { Request } from 'express'
import { AuthService } from './auth.service'
import { RegisterDto } from './dto/register.dto'
import { LoginDto } from './dto/login.dto'
import { RefreshTokenDto } from './dto/refresh-token.dto'
import { PhoneLoginDto } from './dto/phone-login.dto'
import { VerifyOtpDto } from './dto/verify-otp.dto'
import {
  RequestPasswordResetDto,
  ConfirmPasswordResetDto,
} from './dto/reset-password.dto'
import { ChangePasswordDto } from './dto/change-password.dto'

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto)
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginDto, @Req() req: Request) {
    const ip = (req.ip ?? req.headers['x-forwarded-for'] ?? 'unknown') as string
    const userAgent = req.headers['user-agent']
    return this.authService.login(dto, ip, userAgent)
  }

  @Post('login/phone')
  @HttpCode(HttpStatus.OK)
  async requestPhoneLogin(@Body() dto: PhoneLoginDto) {
    return this.authService.requestPhoneLogin(dto)
  }

  @Post('login/phone/verify')
  @HttpCode(HttpStatus.OK)
  async verifyPhoneLogin(@Body() dto: VerifyOtpDto, @Req() req: Request) {
    const ip = (req.ip ?? req.headers['x-forwarded-for'] ?? 'unknown') as string
    const userAgent = req.headers['user-agent']
    return this.authService.verifyPhoneLogin(dto, ip, userAgent)
  }

  @Post('verify-phone')
  @HttpCode(HttpStatus.OK)
  async verifyPhone(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyPhone(dto)
  }

  @Post('password-reset/request')
  @HttpCode(HttpStatus.OK)
  async requestPasswordReset(@Body() dto: RequestPasswordResetDto) {
    return this.authService.requestPasswordReset(dto)
  }

  @Post('password-reset/confirm')
  @HttpCode(HttpStatus.OK)
  async confirmPasswordReset(@Body() dto: ConfirmPasswordResetDto) {
    return this.authService.confirmPasswordReset(dto)
  }

  @Post('change-password')
  @HttpCode(HttpStatus.OK)
  @UseGuards(AuthGuard('jwt'))
  async changePassword(@Req() req: Request, @Body() dto: ChangePasswordDto) {
    const user = req.user as { id: string }
    return this.authService.changePassword(user.id, dto)
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refresh(dto.refresh_token)
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(AuthGuard('jwt'))
  async logout(@Body() dto: RefreshTokenDto) {
    return this.authService.logout(dto.refresh_token)
  }

  @Post('logout-all')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(AuthGuard('jwt'))
  async logoutAll(@Req() req: Request) {
    const user = req.user as { id: string }
    return this.authService.logoutAll(user.id)
  }

  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  async me(@Req() req: Request) {
    return req.user
  }

  @Post('admin/login')
  @HttpCode(HttpStatus.OK)
  async adminLogin(@Body() dto: LoginDto, @Req() req: Request) {
    const ip = (req.ip ?? req.headers['x-forwarded-for'] ?? 'unknown') as string
    const userAgent = req.headers['user-agent']
    return this.authService.login(dto, ip, userAgent)
  }
}
