import { Injectable, BadRequestException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { OrderEntity } from './entities/order.entity'
import { CreateOrderDto } from './dto/create-order.dto'
import { OrderStatus } from '@crab/common-types'

const VALID_TRANSITIONS: Record<OrderStatus, OrderStatus[]> = {
  [OrderStatus.PLACED]: [OrderStatus.CONFIRMED, OrderStatus.CANCELLED],
  [OrderStatus.CONFIRMED]: [OrderStatus.PREPARING, OrderStatus.CANCELLED],
  [OrderStatus.PREPARING]: [OrderStatus.READY, OrderStatus.CANCELLED],
  [OrderStatus.READY]: [OrderStatus.PICKED_UP, OrderStatus.CANCELLED],
  [OrderStatus.PICKED_UP]: [OrderStatus.DELIVERED, OrderStatus.CANCELLED],
  [OrderStatus.DELIVERED]: [],
  [OrderStatus.CANCELLED]: [],
}

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(OrderEntity)
    private readonly orderRepo: Repository<OrderEntity>,
  ) {}

  async create(dto: CreateOrderDto) {
    const subtotal = dto.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
    const delivery_fee = 15000
    const total = subtotal + delivery_fee

    const order = this.orderRepo.create({
      ...dto,
      subtotal,
      delivery_fee,
      total,
      status: OrderStatus.PLACED,
    })
    return this.orderRepo.save(order)
  }

  async findById(id: string) {
    return this.orderRepo.findOneBy({ id })
  }

  async findActiveByUser(userId: string) {
    return this.orderRepo.find({
      where: { user_id: userId },
      order: { created_at: 'DESC' },
    })
  }

  async updateStatus(id: string, newStatus: OrderStatus, driverId?: string) {
    const order = await this.orderRepo.findOneBy({ id })
    if (!order) throw new BadRequestException('Order not found')

    const allowed = VALID_TRANSITIONS[order.status]
    if (!allowed.includes(newStatus)) {
      throw new BadRequestException(
        `Cannot transition from ${order.status} to ${newStatus}`,
      )
    }

    order.status = newStatus
    if (driverId) order.driver_id = driverId
    return this.orderRepo.save(order)
  }
}
