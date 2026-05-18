import {
  IsString,
  IsNumber,
  IsOptional,
  IsEnum,
  IsBoolean,
  IsDateString,
  Min,
} from 'class-validator'
import { PromoType, PromoApplicableTo } from '../entities/promo.entity'

export class CreatePromoDto {
  @IsString() code!: string
  @IsString() name!: string
  @IsOptional() @IsString() description?: string
  @IsEnum(PromoType) type!: PromoType
  @IsNumber() @Min(0) value!: number
  @IsOptional() @IsNumber() @Min(0) minOrderValue?: number
  @IsOptional() @IsNumber() maxDiscount?: number
  @IsOptional() @IsEnum(PromoApplicableTo) applicableTo?: PromoApplicableTo
  @IsOptional() @IsNumber() @Min(1) usageLimitPerUser?: number
  @IsOptional() @IsNumber() totalUsageLimit?: number
  @IsDateString() validFrom!: string
  @IsDateString() validUntil!: string
  @IsOptional() @IsBoolean() isActive?: boolean
  @IsOptional() @IsBoolean() firstRideOnly?: boolean
}

export class ApplyPromoDto {
  @IsString() code!: string
  @IsString() userId!: string
  @IsNumber() @Min(0) orderValue!: number
  @IsOptional() @IsEnum(PromoApplicableTo) context?: PromoApplicableTo
}
