import { IsString, IsOptional, IsNumber } from 'class-validator'

export class RegisterMerchantDto {
  @IsString() businessName!: string
  @IsString() businessType!: string
  @IsString() taxId!: string
  @IsOptional() @IsString() businessLicense?: string
  @IsString() businessAddress!: string
  @IsOptional() @IsNumber() latitude?: number
  @IsOptional() @IsNumber() longitude?: number
}
