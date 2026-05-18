import { IsNumber, IsString, IsOptional, Min } from 'class-validator'

export class TopUpDto {
  @IsNumber() @Min(10000)
  amount!: number

  @IsString()
  paymentMethod!: string

  @IsOptional() @IsString()
  reference?: string
}

export class WithdrawDto {
  @IsNumber() @Min(10000)
  amount!: number

  @IsString()
  bankAccount!: string

  @IsString()
  bankName!: string
}

export class TransferDto {
  @IsString() toUserId!: string
  @IsNumber() @Min(1000) amount!: number
  @IsOptional() @IsString() note?: string
}
