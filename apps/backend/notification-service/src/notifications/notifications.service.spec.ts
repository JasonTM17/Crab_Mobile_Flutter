import { Test, TestingModule } from '@nestjs/testing'
import { getModelToken } from '@nestjs/mongoose'
import { NotificationsService } from './notifications.service'
import { Notification } from './schemas/notification.schema'
import { NotificationPreferences } from '../preferences/schemas/preferences.schema'
import { FcmService } from './fcm.service'

describe('NotificationsService', () => {
  let service: NotificationsService

  const mockNotifModel = {
    create: jest.fn(),
    find: jest.fn(),
    findOneAndUpdate: jest.fn(),
    updateMany: jest.fn(),
    countDocuments: jest.fn(),
    deleteOne: jest.fn(),
    insertMany: jest.fn(),
  }

  const mockPrefsModel = {
    findOne: jest.fn(),
    create: jest.fn(),
    updateOne: jest.fn(),
  }

  const mockFcm = {
    sendToTokens: jest.fn(),
  }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsService,
        { provide: getModelToken(Notification.name), useValue: mockNotifModel },
        { provide: getModelToken(NotificationPreferences.name), useValue: mockPrefsModel },
        { provide: FcmService, useValue: mockFcm },
      ],
    }).compile()

    service = module.get<NotificationsService>(NotificationsService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('markAllRead', () => {
    it('forwards modifiedCount from MongoDB', async () => {
      mockNotifModel.updateMany.mockResolvedValueOnce({ modifiedCount: 7 })
      const result = await service.markAllRead('user-1')
      expect(result).toEqual({ updated: 7 })
      expect(mockNotifModel.updateMany).toHaveBeenCalledWith(
        { userId: 'user-1', read: false },
        expect.objectContaining({ read: true }),
      )
    })
  })

  describe('unreadCount', () => {
    it('returns the number of unread notifications', async () => {
      mockNotifModel.countDocuments.mockResolvedValueOnce(3)
      await expect(service.unreadCount('user-1')).resolves.toBe(3)
      expect(mockNotifModel.countDocuments).toHaveBeenCalledWith({
        userId: 'user-1',
        read: false,
      })
    })
  })

  describe('broadcast', () => {
    it('inserts one document per recipient and reports the count', async () => {
      mockNotifModel.insertMany.mockResolvedValueOnce([])
      const result = await service.broadcast({
        userIds: ['u1', 'u2', 'u3'],
        title: 'Hi',
        body: 'World',
        type: 'PROMO' as never,
      } as never)
      expect(result).toEqual({ sent: 3 })
      expect(mockNotifModel.insertMany).toHaveBeenCalledTimes(1)
      const inserted = mockNotifModel.insertMany.mock.calls[0][0]
      expect(inserted).toHaveLength(3)
      expect(inserted[0]).toMatchObject({ userId: 'u1', title: 'Hi' })
    })
  })
})
