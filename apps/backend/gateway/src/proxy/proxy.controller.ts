import {
  Controller,
  Post,
  Get,
  Put,
  Body,
  Param,
  Headers,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common'
import { AuthGuard } from '@nestjs/passport'
import { ProxyService } from './proxy.service'

@Controller('auth')
export class AuthProxyController {
  constructor(private readonly proxy: ProxyService) {}

  @Post('register')
  async register(@Body() body: unknown) {
    return this.proxy.forwardToAuth('/api/v1/auth/register', 'POST', body)
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() body: unknown) {
    return this.proxy.forwardToAuth('/api/v1/auth/login', 'POST', body)
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() body: unknown) {
    return this.proxy.forwardToAuth('/api/v1/auth/refresh', 'POST', body)
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @UseGuards(AuthGuard('jwt'))
  async logout(
    @Body() body: unknown,
    @Headers('authorization') auth: string,
  ) {
    return this.proxy.forwardToAuth('/api/v1/auth/logout', 'POST', body, {
      authorization: auth,
    })
  }
}

@Controller('users')
export class UserProxyController {
  constructor(private readonly proxy: ProxyService) {}

  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  async getProfile(@Headers('authorization') auth: string) {
    return this.proxy.forwardToUser('/api/v1/users/me', 'GET', undefined, {
      authorization: auth,
    })
  }

  @Put('me')
  @UseGuards(AuthGuard('jwt'))
  async updateProfile(
    @Body() body: unknown,
    @Headers('authorization') auth: string,
  ) {
    return this.proxy.forwardToUser('/api/v1/users/me', 'PUT', body, {
      authorization: auth,
    })
  }

  @Get(':id')
  @UseGuards(AuthGuard('jwt'))
  async getUserById(
    @Param('id') id: string,
    @Headers('authorization') auth: string,
  ) {
    return this.proxy.forwardToUser(`/api/v1/users/${id}`, 'GET', undefined, {
      authorization: auth,
    })
  }
}
