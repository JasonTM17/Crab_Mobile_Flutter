import {
  Controller,
  ForbiddenException,
  Get,
  Req,
  UseGuards,
} from '@nestjs/common'
import type { Request } from 'express'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { AdminDashboardService } from './admin-dashboard.service'

@Controller('admin/dashboard')
@UseGuards(JwtAuthGuard)
export class AdminDashboardController {
  constructor(private readonly service: AdminDashboardService) {}

  @Get()
  async summary(@Req() req: Request) {
    this.requireAdmin(req)

    return {
      success: true,
      data: await this.service.getSummary(),
      statusCode: 200,
    }
  }

  private requireAdmin(req: Request) {
    const user = (req as Request & { user?: { role?: string } }).user
    if (user?.role !== 'ADMIN') {
      throw new ForbiddenException('Admin role required')
    }
  }
}
