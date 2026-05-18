import { IsNumber, Min, Max, IsOptional, IsEnum } from 'class-validator'
import { VehicleType } from '../fare.service'

export class EstimateFareDto {
  @IsNumber() @Min(-90) @Max(90)
  pickup_lat!: number

  @IsNumber() @Min(-180) @Max(180)
  pickup_lng!: number

  @IsNumber() @Min(-90) @Max(90)
  dropoff_lat!: number

  @IsNumber() @Min(-180) @Max(180)
  dropoff_lng!: number

  @IsOptional()
  @IsEnum(VehicleType)
  vehicle_type?: VehicleType
}
