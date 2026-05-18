import { IsString, IsEnum, IsInt, Min, Max, IsOptional, IsArray } from 'class-validator'
import { RatingContext, RatingTargetType } from '../entities/rating.entity'

export class CreateRatingDto {
  @IsString() raterId!: string
  @IsString() targetId!: string
  @IsEnum(RatingTargetType) targetType!: RatingTargetType
  @IsEnum(RatingContext) context!: RatingContext
  @IsString() referenceId!: string
  @IsInt() @Min(1) @Max(5) score!: number
  @IsOptional() @IsString() review?: string
  @IsOptional() @IsArray() tags?: string[]
  @IsOptional() @IsArray() photos?: string[]
}

export class FlagRatingDto {
  @IsString() reason!: string
}
