import { IsString, IsOptional, IsNumber, IsDateString } from 'class-validator'

export class RegisterDriverDto {
  @IsString() licenseNumber!: string
  @IsDateString() licenseExpiry!: string
  @IsString() vehicleType!: string
  @IsString() vehiclePlate!: string
  @IsString() vehicleBrand!: string
  @IsString() vehicleModel!: string
  @IsOptional() @IsString() vehicleColor?: string
  @IsOptional() @IsNumber() vehicleYear?: number
  @IsOptional() @IsString() insuranceNumber?: string
  @IsOptional() @IsDateString() insuranceExpiry?: string
}
