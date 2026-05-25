import { ForbiddenException } from '@nestjs/common'
import { GUARDS_METADATA } from '@nestjs/common/constants'
import { JwtAuthGuard } from '../auth/jwt-auth.guard'
import { AdminDashboardController } from './admin-dashboard.controller'
import { AdminDashboardService } from './admin-dashboard.service'

describe('AdminDashboardController', () => {
  const service = {
    getSummary: jest.fn(),
  }
  const controller = new AdminDashboardController(
    service as unknown as AdminDashboardService,
  ) as unknown as {
    summary(req: { user?: { sub?: string; role?: string } }): Promise<unknown>
  }

  beforeEach(() => {
    jest.clearAllMocks()
    service.getSummary.mockResolvedValue({ totalUsers: 4 })
  })

  it('applies JwtAuthGuard to the controller', () => {
    const guards = Reflect.getMetadata(GUARDS_METADATA, AdminDashboardController) ?? []
    expect(guards).toContain(JwtAuthGuard)
  })

  it('rejects non-admin users', async () => {
    await expect(
      controller.summary({ user: { sub: 'u1', role: 'RIDER' } } as never),
    ).rejects.toThrow(ForbiddenException)
    expect(service.getSummary).not.toHaveBeenCalled()
  })

  it('returns dashboard data for admins', async () => {
    await expect(
      controller.summary({ user: { sub: 'admin-1', role: 'ADMIN' } } as never),
    ).resolves.toEqual({
      success: true,
      data: { totalUsers: 4 },
      statusCode: 200,
    })
    expect(service.getSummary).toHaveBeenCalledTimes(1)
  })
})
