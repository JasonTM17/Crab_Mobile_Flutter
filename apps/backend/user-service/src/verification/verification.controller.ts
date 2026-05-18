import {
  Controller,
  Get,
  Post,
  Put,
  Param,
  Body,
  Query,
} from '@nestjs/common'
import { VerificationService } from './verification.service'
import { RegisterDriverDto } from './dto/driver.dto'
import { RegisterMerchantDto } from './dto/merchant.dto'
import { DocType } from './entities/verification-doc.entity'

@Controller('verification')
export class VerificationController {
  constructor(private readonly service: VerificationService) {}

  @Post('drivers/:userId')
  registerDriver(@Param('userId') userId: string, @Body() dto: RegisterDriverDto) {
    return this.service.registerDriver(userId, dto)
  }

  @Get('drivers/:userId')
  getDriver(@Param('userId') userId: string) {
    return this.service.getDriverProfile(userId)
  }

  @Put('drivers/:userId/approve')
  approveDriver(@Param('userId') userId: string) {
    return this.service.approveDriver(userId)
  }

  @Put('drivers/:userId/reject')
  rejectDriver(@Param('userId') userId: string, @Body('reason') reason: string) {
    return this.service.rejectDriver(userId, reason)
  }

  @Put('drivers/:userId/online')
  setOnline(@Param('userId') userId: string, @Body('isOnline') isOnline: boolean) {
    return this.service.setDriverOnline(userId, isOnline)
  }

  @Get('drivers/admin/pending')
  listPending(@Query('page') page?: string, @Query('limit') limit?: string) {
    return this.service.listPendingDrivers(page ? +page : 1, limit ? +limit : 20)
  }

  @Post('merchants/:userId')
  registerMerchant(
    @Param('userId') userId: string,
    @Body() dto: RegisterMerchantDto,
  ) {
    return this.service.registerMerchant(userId, dto)
  }

  @Get('merchants/:userId')
  getMerchant(@Param('userId') userId: string) {
    return this.service.getMerchantProfile(userId)
  }

  @Put('merchants/:userId/approve')
  approveMerchant(@Param('userId') userId: string) {
    return this.service.approveMerchant(userId)
  }

  @Put('merchants/:userId/reject')
  rejectMerchant(@Param('userId') userId: string, @Body('reason') reason: string) {
    return this.service.rejectMerchant(userId, reason)
  }

  @Post('documents/:userId')
  uploadDoc(
    @Param('userId') userId: string,
    @Body('docType') docType: DocType,
    @Body('fileUrl') fileUrl: string,
  ) {
    return this.service.uploadDocument(userId, docType, fileUrl)
  }

  @Get('documents/:userId')
  getDocs(@Param('userId') userId: string) {
    return this.service.getUserDocuments(userId)
  }

  @Put('documents/:docId/verify')
  verifyDoc(@Param('docId') docId: string, @Body('adminId') adminId: string) {
    return this.service.verifyDocument(docId, adminId)
  }
}
