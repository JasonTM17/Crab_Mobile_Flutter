import { IsString, IsOptional } from 'class-validator'

export class RegisterDeviceDto {
  @IsString()
  deviceId!: string

  @IsOptional()
  @IsString()
  deviceName?: string

  @IsOptional()
  @IsString()
  platform?: string

  @IsOptional()
  @IsString()
  fcmToken?: string
}
