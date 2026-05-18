import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
} from '@nestjs/common'
import { AddressesService } from './addresses.service'
import { CreateAddressDto, UpdateAddressDto } from './dto/address.dto'

@Controller('addresses')
export class AddressesController {
  constructor(private readonly service: AddressesService) {}

  @Post(':userId')
  create(@Param('userId') userId: string, @Body() dto: CreateAddressDto) {
    return this.service.create(userId, dto)
  }

  @Get(':userId')
  list(@Param('userId') userId: string) {
    return this.service.findByUser(userId)
  }

  @Get(':userId/:id')
  findOne(@Param('userId') userId: string, @Param('id') id: string) {
    return this.service.findById(id, userId)
  }

  @Put(':userId/:id')
  update(
    @Param('userId') userId: string,
    @Param('id') id: string,
    @Body() dto: UpdateAddressDto,
  ) {
    return this.service.update(id, userId, dto)
  }

  @Delete(':userId/:id')
  delete(@Param('userId') userId: string, @Param('id') id: string) {
    return this.service.delete(id, userId)
  }
}
