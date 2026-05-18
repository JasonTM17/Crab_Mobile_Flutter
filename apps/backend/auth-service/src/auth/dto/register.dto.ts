import { IsEmail, IsString, MinLength, Matches } from 'class-validator'

export class RegisterDto {
  @IsEmail()
  email!: string

  @IsString()
  @Matches(/^\+?[1-9]\d{7,14}$/, { message: 'phone must be a valid international number' })
  phone!: string

  @IsString()
  @MinLength(8)
  password!: string

  @IsString()
  @MinLength(1)
  firstName!: string

  @IsString()
  @MinLength(1)
  lastName!: string
}
