import { IsNumber, IsString, IsOptional, IsDateString, Min, Max, IsEnum } from 'class-validator'
import { VehicleType } from '../../fare/fare.service'

export class ScheduleRideDto {
  @IsString() rider_id!: string
  @IsNumber() @Min(-90) @Max(90) pickup_lat!: number
  @IsNumber() @Min(-180) @Max(180) pickup_lng!: number
  @IsString() pickup_address!: string
  @IsNumber() @Min(-90) @Max(90) dropoff_lat!: number
  @IsNumber() @Min(-180) @Max(180) dropoff_lng!: number
  @IsString() dropoff_address!: string
  @IsDateString() scheduled_at!: string
  @IsOptional() @IsEnum(VehicleType) vehicle_type?: VehicleType
  @IsOptional() @IsString() payment_method?: string
}
