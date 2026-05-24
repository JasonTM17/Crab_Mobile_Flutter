import { ForbiddenException } from '@nestjs/common'
import { ProxyController } from './proxy.controller'
import { ProxyService } from './proxy.service'

describe('ProxyController verification access', () => {
  const proxy = {
    forward: jest.fn(),
    getCircuitStatus: jest.fn().mockReturnValue({}),
  }
  const res = {
    json: jest.fn(),
    status: jest.fn().mockReturnThis(),
  }
  const controller = new ProxyController(proxy as unknown as ProxyService)

  beforeEach(() => {
    jest.clearAllMocks()
    proxy.forward.mockResolvedValue({ ok: true })
  })

  it('rejects verification routes for non-admin users', async () => {
    await expect(
      controller.verification(
        {
          path: '/api/v1/verification/drivers/admin/pending',
          method: 'GET',
          headers: {},
          user: { sub: 'u1', role: 'RIDER' },
        } as never,
        res as never,
        undefined,
      ),
    ).rejects.toThrow(ForbiddenException)
    expect(proxy.forward).not.toHaveBeenCalled()
  })

  it('forwards verification routes for admins', async () => {

    await expect(
      controller.verification(
        {
          path: '/api/v1/verification/drivers/admin/pending',
          method: 'GET',
          headers: {},
          user: { sub: 'admin-1', role: 'ADMIN' },
        } as never,
        { json: jest.fn() } as never,
        undefined,
      ),
    ).resolves.toBeUndefined()
    expect(proxy.forward).toHaveBeenCalled()
  })
})
