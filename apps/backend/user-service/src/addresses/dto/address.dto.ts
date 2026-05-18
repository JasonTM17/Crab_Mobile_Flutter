import { IsString, IsNumber, IsOptional, IsBoolean, Min, Max } from 'class-validator'

export class CreateAddressDto {
  @IsString() label!: string
  @IsString() address!: string
  @IsNumber() @Min(-90) @Max(90) latitude!: number
  @IsNumber() @Min(-180) @Max(180) longitude!: number
  @IsOptional() @IsBoolean() isDefault?: boolean
  @IsOptional() @IsString() notes?: string
}

export class UpdateAddressDto {
  @IsOptional() @IsString() label?: string
  @IsOptional() @IsString() address?: string
  @IsOptional() @IsNumber() latitude?: number
  @IsOptional() @IsNumber() longitude?: number
  @IsOptional() @IsBoolean() isDefault?: boolean
  @IsOptional() @IsString() notes?: string
}
