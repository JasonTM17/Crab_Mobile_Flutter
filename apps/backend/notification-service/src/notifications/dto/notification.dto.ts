import { IsString, IsEnum, IsOptional, IsArray, IsObject } from 'class-validator'
import { NotificationType, NotificationChannel } from '../schemas/notification.schema'

export class CreateNotificationDto {
  @IsString() userId!: string
  @IsString() title!: string
  @IsString() body!: string
  @IsEnum(NotificationType) type!: NotificationType
  @IsOptional() @IsArray() channels?: NotificationChannel[]
  @IsOptional() @IsObject() data?: Record<string, any>
  @IsOptional() @IsString() imageUrl?: string
  @IsOptional() @IsString() deepLink?: string
}

export class BroadcastDto {
  @IsArray() userIds!: string[]
  @IsString() title!: string
  @IsString() body!: string
  @IsEnum(NotificationType) type!: NotificationType
  @IsOptional() @IsObject() data?: Record<string, any>
  @IsOptional() @IsString() imageUrl?: string
  @IsOptional() @IsString() deepLink?: string
}
