import { IsString, Matches, Length } from 'class-validator'

export class VerifyOtpDto {
  @IsString()
  @Matches(/^\+?[1-9]\d{7,14}$/, { message: 'phone must be a valid international number' })
  phone!: string

  @IsString()
  @Length(6, 6, { message: 'OTP must be exactly 6 digits' })
  code!: string
}
