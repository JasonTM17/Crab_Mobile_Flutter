import { IsString, IsEnum, IsOptional, IsObject } from 'class-validator'
import { MessageType } from '../schemas/message.schema'

export class SendMessageDto {
  @IsString()
  roomId!: string

  @IsString()
  senderId!: string

  @IsString()
  content!: string

  @IsOptional()
  @IsEnum(MessageType)
  type?: MessageType

  @IsOptional()
  @IsObject()
  metadata?: Record<string, any>
}

export class EditMessageDto {
  @IsString()
  content!: string
}
