import { IsString, IsNumber, IsOptional, IsBoolean, Min, Max } from 'class-validator'

export class CreateRestaurantDto {
  @IsString() merchantId!: string
  @IsString() name!: string
  @IsOptional() @IsString() description?: string
  @IsOptional() @IsString() coverImageUrl?: string
  @IsOptional() @IsString() logoUrl?: string
  @IsString() phone!: string
  @IsString() address!: string
  @IsOptional() @IsString() city?: string
  @IsNumber() @Min(-90) @Max(90) latitude!: number
  @IsNumber() @Min(-180) @Max(180) longitude!: number
  @IsOptional() @IsString() cuisineType?: string
  @IsOptional() @IsNumber() avgPrepTimeMin?: number
  @IsOptional() @IsNumber() deliveryFee?: number
  @IsOptional() @IsNumber() minOrderValue?: number
  @IsOptional() @IsString() openTime?: string
  @IsOptional() @IsString() closeTime?: string
  @IsOptional() @IsBoolean() acceptsCod?: boolean
}

export class UpdateRestaurantDto {
  @IsOptional() @IsString() name?: string
  @IsOptional() @IsString() description?: string
  @IsOptional() @IsString() coverImageUrl?: string
  @IsOptional() @IsString() logoUrl?: string
  @IsOptional() @IsString() phone?: string
  @IsOptional() @IsString() address?: string
  @IsOptional() @IsNumber() latitude?: number
  @IsOptional() @IsNumber() longitude?: number
  @IsOptional() @IsString() cuisineType?: string
  @IsOptional() @IsNumber() avgPrepTimeMin?: number
  @IsOptional() @IsNumber() deliveryFee?: number
  @IsOptional() @IsBoolean() isOpen?: boolean
}

export class SearchRestaurantsDto {
  @IsOptional() @IsNumber() @Min(-90) @Max(90) latitude?: number
  @IsOptional() @IsNumber() @Min(-180) @Max(180) longitude?: number
  @IsOptional() @IsNumber() radiusKm?: number
  @IsOptional() @IsString() cuisineType?: string
  @IsOptional() @IsString() query?: string
  @IsOptional() @IsNumber() page?: number
  @IsOptional() @IsNumber() limit?: number
}
