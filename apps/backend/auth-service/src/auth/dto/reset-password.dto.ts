import { IsString, MinLength, Matches, Length } from 'class-validator'

export class RequestPasswordResetDto {
  @IsString()
  @Matches(/^\+?[1-9]\d{7,14}$/, { message: 'phone must be a valid international number' })
  phone!: string
}

export class ConfirmPasswordResetDto {
  @IsString()
  @Matches(/^\+?[1-9]\d{7,14}$/, { message: 'phone must be a valid international number' })
  phone!: string

  @IsString()
  @Length(6, 6)
  code!: string

  @IsString()
  @MinLength(8)
  newPassword!: string
}
