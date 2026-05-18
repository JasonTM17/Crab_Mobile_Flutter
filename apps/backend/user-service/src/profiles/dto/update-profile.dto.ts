import { IsOptional, IsString, IsDateString, MaxLength } from 'class-validator'

export class UpdateProfileDto {
  @IsOptional() @IsString() firstName?: string
  @IsOptional() @IsString() lastName?: string
  @IsOptional() @IsDateString() dateOfBirth?: string
  @IsOptional() @IsString() gender?: string
  @IsOptional() @IsString() @MaxLength(500) bio?: string
  @IsOptional() @IsString() preferredLanguage?: string
  @IsOptional() @IsString() preferredCurrency?: string
  @IsOptional() @IsString() emergencyContactName?: string
  @IsOptional() @IsString() emergencyContactPhone?: string
  @IsOptional() @IsString() avatarUrl?: string
}

export class CreateProfileDto {
  @IsString() userId!: string
  @IsString() email!: string
  @IsString() phone!: string
  @IsString() firstName!: string
  @IsString() lastName!: string
}
