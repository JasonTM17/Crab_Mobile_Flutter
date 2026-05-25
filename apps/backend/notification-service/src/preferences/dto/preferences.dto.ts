import { IsBoolean, IsOptional, IsString } from 'class-validator'

export class UpdatePreferencesDto {
  @IsOptional() @IsBoolean() pushEnabled?: boolean
  @IsOptional() @IsBoolean() emailEnabled?: boolean
  @IsOptional() @IsBoolean() smsEnabled?: boolean
  @IsOptional() @IsBoolean() rideEnabled?: boolean
  @IsOptional() @IsBoolean() orderEnabled?: boolean
  @IsOptional() @IsBoolean() chatEnabled?: boolean
  @IsOptional() @IsBoolean() promoEnabled?: boolean
  @IsOptional() @IsBoolean() systemEnabled?: boolean
}

export class FcmTokenDto {
  @IsString() token!: string
}
