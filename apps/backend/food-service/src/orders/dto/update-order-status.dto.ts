import { IsEnum, IsOptional, IsString } from 'class-validator'
import { OrderStatus } from '@crab/common-types'

export class UpdateOrderStatusDto {
  @IsEnum(OrderStatus)
  status!: OrderStatus

  @IsOptional()
  @IsString()
  driver_id?: string
}
