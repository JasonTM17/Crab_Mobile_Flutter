import { ForbiddenException, UnauthorizedException } from '@nestjs/common'
import { NotificationsController } from './notifications.controller'

type HeaderAwareNotificationsController = {
  list(
    authenticatedUserId: string | undefined,
    routeUserId: string,
    page?: string,
    limit?: string,
    unreadOnly?: string,
  ): unknown
  markRead(authenticatedUserId: string | undefined, id: string): unknown
  delete(
    authenticatedUserId: string | undefined,
    id: string,
  ): Promise<{ acknowledged: boolean; deletedCount: number }>
}

describe('NotificationsController ownership', () => {
  const service = {
    send: jest.fn(),
    broadcast: jest.fn(),
    list: jest.fn(),
    unreadCount: jest.fn(),
    markRead: jest.fn(),
    markAllRead: jest.fn(),
    delete: jest.fn(),
  }

  let controller: NotificationsController
  let headerAwareController: HeaderAwareNotificationsController

  beforeEach(() => {
    jest.clearAllMocks()
    controller = new NotificationsController(service as never)
    headerAwareController = controller as unknown as HeaderAwareNotificationsController
  })

  it('rejects list requests without authenticated user context', () => {
    expect(() => headerAwareController.list(undefined, 'user-1')).toThrow(UnauthorizedException)
    expect(service.list).not.toHaveBeenCalled()
  })

  it('rejects list requests for a different user', () => {
    expect(() => headerAwareController.list('user-1', 'user-2')).toThrow(ForbiddenException)
    expect(service.list).not.toHaveBeenCalled()
  })

  it('lists notifications for the authenticated user only', () => {
    headerAwareController.list('user-1', 'user-1', '2', '10', 'true')

    expect(service.list).toHaveBeenCalledWith('user-1', 2, 10, true)
  })

  it('uses the authenticated user when marking a notification read', () => {
    headerAwareController.markRead('user-1', 'notif-1')

    expect(service.markRead).toHaveBeenCalledWith('notif-1', 'user-1')
  })

  it('uses the authenticated user when deleting a notification', async () => {
    service.delete.mockResolvedValueOnce({ acknowledged: true, deletedCount: 1 })

    await headerAwareController.delete('user-1', 'notif-1')

    expect(service.delete).toHaveBeenCalledWith('notif-1', 'user-1')
  })
})
