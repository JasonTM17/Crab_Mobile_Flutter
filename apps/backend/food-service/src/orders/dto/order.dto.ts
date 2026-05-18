import { IsArray, IsNumber, IsOptional, IsString, ValidateNested, Min, Max } from 'class-validator'
import { Type } from 'class-transformer'

export class OrderItemInput {
  @IsString() menuItemId!: string
  @IsNumber() @Min(1) quantity!: number
  @IsOptional() @IsString() notes?: string
  @IsOptional() options?: Record<string, any>
}

export class CreateOrderDto {
  @IsString() customerId!: string
  @IsString() restaurantId!: string
  @IsArray() @ValidateNested({ each: true }) @Type(() => OrderItemInput)
  items!: OrderItemInput[]
  @IsNumber() @Min(-90) @Max(90) deliveryLat!: number
  @IsNumber() @Min(-180) @Max(180) deliveryLng!: number
  @IsString() deliveryAddress!: string
  @IsOptional() @IsString() deliveryNotes?: string
  @IsOptional() @IsString() paymentMethod?: string
  @IsOptional() @IsString() promoCode?: string
}

export class UpdateOrderStatusDto {
  @IsString() status!: string
  @IsOptional() @IsString() driverId?: string
  @IsOptional() @IsString() reason?: string
}
