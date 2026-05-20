import { Test, TestingModule } from '@nestjs/testing'
import { getRepositoryToken } from '@nestjs/typeorm'
import { DataSource } from 'typeorm'
import { BadRequestException, NotFoundException } from '@nestjs/common'
import { OrderStatus } from '@crab/common-types'
import { OrdersService } from './orders.service'
import { OrderEntity } from './entities/order.entity'
import { OrderItemEntity } from './entities/order-item.entity'
import { MenuItemEntity } from '../menus/entities/menu-item.entity'
import { RestaurantEntity } from '../restaurants/entities/restaurant.entity'

describe('OrdersService', () => {
  let service: OrdersService

  const mockOrderRepo = {
    findOne: jest.fn(),
    find: jest.fn(),
    update: jest.fn(),
    createQueryBuilder: jest.fn(),
  }
  const mockItemRepo = {}
  const mockMenuItemRepo = {}
  const mockRestaurantRepo = { findOne: jest.fn() }
  const mockDataSource: Partial<DataSource> = { transaction: jest.fn() }

  beforeEach(async () => {
    jest.clearAllMocks()
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OrdersService,
        { provide: getRepositoryToken(OrderEntity), useValue: mockOrderRepo },
        { provide: getRepositoryToken(OrderItemEntity), useValue: mockItemRepo },
        { provide: getRepositoryToken(MenuItemEntity), useValue: mockMenuItemRepo },
        { provide: getRepositoryToken(RestaurantEntity), useValue: mockRestaurantRepo },
        { provide: DataSource, useValue: mockDataSource },
      ],
    }).compile()

    service = module.get<OrdersService>(OrdersService)
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('create', () => {
    it('rejects empty item list', async () => {
      await expect(
        service.create({ restaurantId: 'r1', customerId: 'c1', items: [] } as never),
      ).rejects.toThrow(BadRequestException)
    })

    it('rejects when restaurant not found', async () => {
      mockRestaurantRepo.findOne.mockResolvedValueOnce(null)
      await expect(
        service.create({
          restaurantId: 'missing',
          customerId: 'c1',
          items: [{ menuItemId: 'm1', quantity: 1 }],
        } as never),
      ).rejects.toThrow(NotFoundException)
    })

    it('rejects when restaurant is closed', async () => {
      mockRestaurantRepo.findOne.mockResolvedValueOnce({ id: 'r1', isOpen: false })
      await expect(
        service.create({
          restaurantId: 'r1',
          customerId: 'c1',
          items: [{ menuItemId: 'm1', quantity: 1 }],
        } as never),
      ).rejects.toThrow(BadRequestException)
    })
  })

  describe('updateStatus', () => {
    it('rejects invalid status transitions', async () => {
      mockOrderRepo.findOne.mockResolvedValueOnce({
        id: 'o1',
        status: OrderStatus.DELIVERED,
        items: [],
      })
      await expect(
        service.updateStatus('o1', { status: OrderStatus.CONFIRMED } as never),
      ).rejects.toThrow(BadRequestException)
    })

    it('allows PLACED -> CONFIRMED', async () => {
      mockOrderRepo.findOne
        .mockResolvedValueOnce({
          id: 'o1',
          status: OrderStatus.PLACED,
          items: [],
        })
        .mockResolvedValueOnce({
          id: 'o1',
          status: OrderStatus.CONFIRMED,
          items: [],
        })

      const result = await service.updateStatus('o1', {
        status: OrderStatus.CONFIRMED,
      } as never)

      expect(mockOrderRepo.update).toHaveBeenCalledWith(
        'o1',
        expect.objectContaining({ status: OrderStatus.CONFIRMED }),
      )
      expect(result.status).toBe(OrderStatus.CONFIRMED)
    })
  })
})
