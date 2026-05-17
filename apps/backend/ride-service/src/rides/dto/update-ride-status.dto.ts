import { IsEnum, IsOptional, IsString } from 'class-validator'
import { RideStatus } from '@crab/common-types'

export class UpdateRideStatusDto {
  @IsEnum(RideStatus)
  status!: RideStatus

  @IsOptional()
  @IsString()
  driver_id?: string
}
