import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Between, DataSource, FindOptionsWhere, Repository } from 'typeorm'
import { OrderStatus } from '@crab/common-types'
import { OrderEntity } from './entities/order.entity'
import { OrderItemEntity } from './entities/order-item.entity'
import { MenuItemEntity } from '../menus/entities/menu-item.entity'
import { RestaurantEntity } from '../restaurants/entities/restaurant.entity'
import { CreateOrderDto, UpdateOrderStatusDto } from './dto/order.dto'

@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name)

  constructor(
    @InjectRepository(OrderEntity)
    private readonly orderRepo: Repository<OrderEntity>,
    @InjectRepository(OrderItemEntity)
    private readonly itemRepo: Repository<OrderItemEntity>,
    @InjectRepository(MenuItemEntity)
    private readonly menuItemRepo: Repository<MenuItemEntity>,
    @InjectRepository(RestaurantEntity)
    private readonly restaurantRepo: Repository<RestaurantEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async create(dto: CreateOrderDto): Promise<OrderEntity> {
    if (dto.items.length === 0) {
      throw new BadRequestException('Order must have at least 1 item')
    }

    const restaurant = await this.restaurantRepo.findOne({
      where: { id: dto.restaurantId },
    })
    if (!restaurant) throw new NotFoundException('Restaurant not found')
    if (!restaurant.isOpen) throw new BadRequestException('Restaurant is closed')

    return this.dataSource.transaction(async (manager) => {
      let subtotal = 0
      const orderItems: OrderItemEntity[] = []

      for (const i of dto.items) {
        const m = await manager.findOne(MenuItemEntity, { where: { id: i.menuItemId } })
        if (!m) throw new NotFoundException(`Menu item ${i.menuItemId} not found`)
        if (!m.isAvailable) throw new BadRequestException(`${m.name} not available`)
        const price = Number(m.discountPrice ?? m.price)
        subtotal += price * i.quantity
        orderItems.push(
          manager.create(OrderItemEntity, {
            menuItemId: m.id,
            name: m.name,
            price,
            quantity: i.quantity,
            notes: i.notes,
            options: i.options,
          }),
        )
      }

      if (subtotal < Number(restaurant.minOrderValue)) {
        throw new BadRequestException(`Minimum order value: ${restaurant.minOrderValue}`)
      }

      const deliveryFee = Number(restaurant.deliveryFee)
      const total = subtotal + deliveryFee

      const order = manager.create(OrderEntity, {
        customerId: dto.customerId,
        restaurantId: dto.restaurantId,
        status: OrderStatus.PLACED,
        deliveryLat: dto.deliveryLat,
        deliveryLng: dto.deliveryLng,
        deliveryAddress: dto.deliveryAddress,
        deliveryNotes: dto.deliveryNotes,
        subtotal,
        deliveryFee,
        discount: 0,
        total,
        paymentMethod: dto.paymentMethod ?? 'WALLET',
        promoCode: dto.promoCode,
      })
      const saved = await manager.save(order)

      for (const item of orderItems) {
        item.orderId = saved.id
      }
      await manager.save(orderItems)
      saved.items = orderItems

      for (const i of dto.items) {
        await manager.increment(MenuItemEntity, { id: i.menuItemId }, 'totalSold', i.quantity)
      }
      await manager.increment(RestaurantEntity, { id: dto.restaurantId }, 'totalOrders', 1)

      this.logger.log(`Order ${saved.id} created for customer ${dto.customerId}`)
      return saved
    })
  }

  async findById(id: string): Promise<OrderEntity> {
    const order = await this.orderRepo.findOne({ where: { id }, relations: ['items'] })
    if (!order) throw new NotFoundException(`Order ${id} not found`)
    return order
  }

  async findByCustomer(customerId: string, limit = 50) {
    return this.orderRepo.find({
      where: { customerId },
      relations: ['items'],
      order: { createdAt: 'DESC' },
      take: limit,
    })
  }

  async findByRestaurant(restaurantId: string, status?: OrderStatus) {
    const where: any = { restaurantId }
    if (status) where.status = status
    return this.orderRepo.find({
      where,
      relations: ['items'],
      order: { createdAt: 'DESC' },
      take: 100,
    })
  }

  async list(opts: {
    page?: number
    limit?: number
    status?: OrderStatus
    fromDate?: Date
    toDate?: Date
  } = {}) {
    const page = opts.page ?? 1
    const limit = opts.limit ?? 20
    const where: FindOptionsWhere<OrderEntity> = {}

    if (opts.status) where.status = opts.status
    if (opts.fromDate && opts.toDate) {
      where.createdAt = Between(opts.fromDate, opts.toDate)
    }

    const [data, total] = await this.orderRepo.findAndCount({
      where,
      relations: ['items'],
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
    })

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) }
  }

  async findByDriver(driverId: string, limit = 50) {
    return this.orderRepo.find({
      where: { driverId },
      relations: ['items'],
      order: { createdAt: 'DESC' },
      take: limit,
    })
  }

  async findActive(customerId: string) {
    return this.orderRepo.find({
      where: [
        { customerId, status: OrderStatus.PLACED },
        { customerId, status: OrderStatus.CONFIRMED },
        { customerId, status: OrderStatus.PREPARING },
        { customerId, status: OrderStatus.READY },
        { customerId, status: OrderStatus.PICKED_UP },
      ],
      relations: ['items'],
      order: { createdAt: 'DESC' },
    })
  }

  // Allowed state transitions for orders. Anything not listed throws 400.
  private readonly transitions: Record<OrderStatus, OrderStatus[]> = {
    [OrderStatus.PLACED]: [OrderStatus.CONFIRMED, OrderStatus.CANCELLED],
    [OrderStatus.CONFIRMED]: [OrderStatus.PREPARING, OrderStatus.CANCELLED],
    [OrderStatus.PREPARING]: [OrderStatus.READY, OrderStatus.CANCELLED],
    [OrderStatus.READY]: [OrderStatus.PICKED_UP, OrderStatus.CANCELLED],
    [OrderStatus.PICKED_UP]: [OrderStatus.DELIVERED],
    [OrderStatus.DELIVERED]: [],
    [OrderStatus.CANCELLED]: [],
  }

  async updateStatus(id: string, dto: UpdateOrderStatusDto): Promise<OrderEntity> {
    const order = await this.findById(id)
    const next = dto.status as OrderStatus
    const allowed = this.transitions[order.status] ?? []
    if (!allowed.includes(next)) {
      throw new BadRequestException(
        `Invalid status transition: ${order.status} → ${next}`,
      )
    }

    const updates: Partial<OrderEntity> = { status: next }

    switch (next) {
      case OrderStatus.CONFIRMED:
        updates.confirmedAt = new Date()
        break
      case OrderStatus.READY:
        updates.preparedAt = new Date()
        break
      case OrderStatus.PICKED_UP:
        updates.pickedUpAt = new Date()
        if (dto.driverId) updates.driverId = dto.driverId
        break
      case OrderStatus.DELIVERED:
        updates.deliveredAt = new Date()
        updates.paid = true
        break
      case OrderStatus.CANCELLED:
        updates.cancelledAt = new Date()
        updates.cancellationReason = dto.reason
        break
    }

    await this.orderRepo.update(id, updates)
    return this.findById(id)
  }

  async assignDriver(id: string, driverId: string) {
    await this.orderRepo.update(id, { driverId })
    return this.findById(id)
  }

  async getStats(restaurantId: string, days = 30) {
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000)
    const orders = await this.orderRepo
      .createQueryBuilder('o')
      .where('o.restaurantId = :restaurantId', { restaurantId })
      .andWhere('o.createdAt >= :since', { since })
      .getMany()
    const completed = orders.filter((o) => o.status === OrderStatus.DELIVERED)
    return {
      restaurantId,
      days,
      totalOrders: orders.length,
      completedOrders: completed.length,
      revenue: completed.reduce((s: number, o: OrderEntity) => s + Number(o.total), 0),
      cancelled: orders.filter((o) => o.status === OrderStatus.CANCELLED).length,
    }
  }
}
