import { IsString, Matches } from 'class-validator'

export class PhoneLoginDto {
  @IsString()
  @Matches(/^\+?[1-9]\d{7,14}$/, { message: 'phone must be a valid international number' })
  phone!: string
}
