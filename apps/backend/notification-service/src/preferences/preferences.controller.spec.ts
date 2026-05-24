import { ForbiddenException, UnauthorizedException } from '@nestjs/common'
import { PreferencesController } from './preferences.controller'

type HeaderAwarePreferencesController = {
  get(authenticatedUserId: string | undefined, routeUserId: string): unknown
  update(
    authenticatedUserId: string | undefined,
    routeUserId: string,
    body: Record<string, unknown>,
  ): unknown
  addToken(
    authenticatedUserId: string | undefined,
    routeUserId: string,
    body: { token: string },
  ): unknown
  removeToken(
    authenticatedUserId: string | undefined,
    routeUserId: string,
    body: { token: string },
  ): unknown
}

describe('PreferencesController ownership', () => {
  const service = {
    getOrCreate: jest.fn(),
    update: jest.fn(),
    addFcmToken: jest.fn(),
    removeFcmToken: jest.fn(),
  }

  let controller: PreferencesController
  let headerAwareController: HeaderAwarePreferencesController

  beforeEach(() => {
    jest.clearAllMocks()
    controller = new PreferencesController(service as never)
    headerAwareController = controller as unknown as HeaderAwarePreferencesController
  })

  it('rejects preferences requests without authenticated user context', () => {
    expect(() => headerAwareController.get(undefined, 'user-1')).toThrow(UnauthorizedException)
    expect(service.getOrCreate).not.toHaveBeenCalled()
  })

  it('rejects preferences requests for a different user', () => {
    expect(() => headerAwareController.get('user-1', 'user-2')).toThrow(ForbiddenException)
    expect(service.getOrCreate).not.toHaveBeenCalled()
  })

  it('uses the authenticated user when updating preferences', () => {
    const body = { pushEnabled: false }

    headerAwareController.update('user-1', 'user-1', body)

    expect(service.update).toHaveBeenCalledWith('user-1', body)
  })

  it('uses the authenticated user when adding an FCM token', () => {
    headerAwareController.addToken('user-1', 'user-1', { token: 'fcm-token' })

    expect(service.addFcmToken).toHaveBeenCalledWith('user-1', 'fcm-token')
  })

  it('uses the authenticated user when removing an FCM token', () => {
    headerAwareController.removeToken('user-1', 'user-1', { token: 'fcm-token' })

    expect(service.removeFcmToken).toHaveBeenCalledWith('user-1', 'fcm-token')
  })
})
