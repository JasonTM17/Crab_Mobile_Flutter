import { IsString, IsNumber, IsOptional, IsArray, IsBoolean } from 'class-validator'

export class CreateMenuItemDto {
  @IsString()
  restaurant_id!: string

  @IsString()
  name!: string

  @IsOptional()
  @IsString()
  description?: string

  @IsNumber()
  price!: number

  @IsOptional()
  @IsString()
  image_url?: string

  @IsString()
  category!: string

  @IsOptional()
  @IsBoolean()
  is_available?: boolean

  @IsOptional()
  @IsArray()
  variants?: { name: string; price: number }[]

  @IsOptional()
  @IsArray()
  addons?: { name: string; price: number }[]
}
