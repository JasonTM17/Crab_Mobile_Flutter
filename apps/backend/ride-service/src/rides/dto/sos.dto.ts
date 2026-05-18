import { IsString, IsOptional, IsNumber } from 'class-validator'

export class SosDto {
  @IsOptional() @IsString() message?: string
  @IsOptional() @IsNumber() latitude?: number
  @IsOptional() @IsNumber() longitude?: number
}
