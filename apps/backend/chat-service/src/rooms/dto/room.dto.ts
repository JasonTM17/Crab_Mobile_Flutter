import { IsString, IsArray, ArrayMinSize, IsEnum, IsOptional } from 'class-validator'
import { RoomType } from '../schemas/room.schema'

export class CreateRoomDto {
  @IsEnum(RoomType)
  type!: RoomType

  @IsArray()
  @ArrayMinSize(2)
  participants!: string[]

  @IsOptional()
  @IsString()
  referenceId?: string
}
