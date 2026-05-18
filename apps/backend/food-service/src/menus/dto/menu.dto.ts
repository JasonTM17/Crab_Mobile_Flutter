import { IsString, IsNumber, IsOptional, IsBoolean, Min } from 'class-validator'

export class CreateCategoryDto {
  @IsString() restaurantId!: string
  @IsString() name!: string
  @IsOptional() @IsString() description?: string
  @IsOptional() @IsNumber() sortOrder?: number
}

export class UpdateCategoryDto {
  @IsOptional() @IsString() name?: string
  @IsOptional() @IsString() description?: string
  @IsOptional() @IsNumber() sortOrder?: number
  @IsOptional() @IsBoolean() isActive?: boolean
}

export class CreateMenuItemDto {
  @IsString() restaurantId!: string
  @IsString() categoryId!: string
  @IsString() name!: string
  @IsOptional() @IsString() description?: string
  @IsOptional() @IsString() imageUrl?: string
  @IsNumber() @Min(0) price!: number
  @IsOptional() @IsNumber() discountPrice?: number
  @IsOptional() @IsNumber() prepTimeMin?: number
  @IsOptional() options?: Record<string, any>
}

export class UpdateMenuItemDto {
  @IsOptional() @IsString() categoryId?: string
  @IsOptional() @IsString() name?: string
  @IsOptional() @IsString() description?: string
  @IsOptional() @IsString() imageUrl?: string
  @IsOptional() @IsNumber() price?: number
  @IsOptional() @IsNumber() discountPrice?: number
  @IsOptional() @IsBoolean() isAvailable?: boolean
  @IsOptional() @IsBoolean() isFeatured?: boolean
}
