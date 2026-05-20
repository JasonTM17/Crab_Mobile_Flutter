import { Test, TestingModule } from '@nestjs/testing'
import { getModelToken } from '@nestjs/mongoose'
import { ForbiddenException, NotFoundException } from '@nestjs/common'
import { MessagesService } from './messages.service'
import { ChatMessage } from './schemas/message.schema'
import { RoomsService } from '../rooms/rooms.service'

describe('MessagesService', () => {
  let service: MessagesService

  const mockModel = {
    create: jest.fn(),
    find: jest.fn(),
    findById: jest.fn(),
    findByIdAndUpdate: jest.fn(),
    countDocuments: jest.fn(),
    findOne: jest.fn(),
    updateMany: jest.fn(),
  }

  const mockRoomsService = {
    findById: jest.fn(),
    updateLastMessage: jest.fn(),
    markRead: jest.fn(),
  }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MessagesService,
        { provide: getModelToken(ChatMessage.name), useValue: mockModel },
        { provide: RoomsService, useValue: mockRoomsService },
      ],
    }).compile()

    service = module.get<MessagesService>(MessagesService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('send', () => {
    it('throws ForbiddenException when sender is not a room participant', async () => {
      mockRoomsService.findById.mockResolvedValueOnce({
        _id: 'room-1',
        participants: ['user-A', 'user-B'],
      })

      await expect(
        service.send({
          roomId: 'room-1',
          senderId: 'intruder',
          content: 'hi',
        } as never),
      ).rejects.toThrow(ForbiddenException)
    })

    it('persists the message when sender is a participant', async () => {
      mockRoomsService.findById.mockResolvedValueOnce({
        _id: 'room-1',
        participants: ['user-A', 'user-B'],
      })
      mockModel.create.mockResolvedValueOnce({ _id: 'msg-1', content: 'hello' })

      const result = await service.send({
        roomId: 'room-1',
        senderId: 'user-A',
        content: 'hello',
      } as never)

      expect(result).toEqual({ _id: 'msg-1', content: 'hello' })
      expect(mockModel.create).toHaveBeenCalledTimes(1)
      expect(mockRoomsService.updateLastMessage).toHaveBeenCalledWith(
        'room-1',
        expect.any(String),
        'user-A',
      )
    })
  })

  describe('edit', () => {
    it('throws NotFoundException when message id is unknown', async () => {
      mockModel.findById.mockResolvedValueOnce(null)
      await expect(
        service.edit('missing', 'user-A', { content: 'x' } as never),
      ).rejects.toThrow(NotFoundException)
    })

    it('throws ForbiddenException when editing someone else\'s message', async () => {
      mockModel.findById.mockResolvedValueOnce({
        senderId: 'user-A',
        save: jest.fn(),
      })
      await expect(
        service.edit('msg-1', 'user-B', { content: 'x' } as never),
      ).rejects.toThrow(ForbiddenException)
    })
  })
})
