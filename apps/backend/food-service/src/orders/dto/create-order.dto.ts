import { IsString, IsNumber, IsArray, IsOptional, ValidateNested } from 'class-validator'
import { Type } from 'class-transformer'

class OrderItemDto {
  @IsString()
  menu_item_id!: string

  @IsString()
  name!: string

  @IsNumber()
  quantity!: number

  @IsNumber()
  price!: number

  @IsOptional()
  @IsString()
  variant?: string

  @IsOptional()
  @IsArray()
  addons?: string[]
}

export class CreateOrderDto {
  @IsString()
  user_id!: string

  @IsString()
  restaurant_id!: string

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items!: OrderItemDto[]

  @IsString()
  delivery_address!: string

  @IsNumber()
  delivery_lat!: number

  @IsNumber()
  delivery_lng!: number

  @IsOptional()
  @IsString()
  notes?: string
}
