import { IsString, IsNumber, IsLatitude, IsLongitude, IsEnum, IsOptional } from 'class-validator'
import { VehicleType } from '../../fare/fare.service'

export class CreateRideDto {
  @IsString()
  rider_id!: string

  @IsNumber()
  @IsLatitude()
  pickup_lat!: number

  @IsNumber()
  @IsLongitude()
  pickup_lng!: number

  @IsString()
  pickup_address!: string

  @IsNumber()
  @IsLatitude()
  dropoff_lat!: number

  @IsNumber()
  @IsLongitude()
  dropoff_lng!: number

  @IsString()
  dropoff_address!: string

  @IsOptional()
  @IsEnum(VehicleType)
  vehicle_type?: VehicleType
}

export class EstimateRideDto {
  @IsNumber()
  @IsLatitude()
  pickup_lat!: number

  @IsNumber()
  @IsLongitude()
  pickup_lng!: number

  @IsNumber()
  @IsLatitude()
  dropoff_lat!: number

  @IsNumber()
  @IsLongitude()
  dropoff_lng!: number
}
