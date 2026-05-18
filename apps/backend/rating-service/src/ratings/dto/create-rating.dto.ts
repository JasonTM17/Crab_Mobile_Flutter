import { IsString, IsNumber, Min, Max, IsOptional } from 'class-validator'

export class CreateRatingDto {
  @IsString()
  targetType: string

  @IsString()
  targetId: string

  @IsNumber()
  @Min(1)
  @Max(5)
  score: number

  @IsOptional()
  @IsString()
  rideId?: string

  @IsOptional()
  @IsString()
  orderId?: string
}
