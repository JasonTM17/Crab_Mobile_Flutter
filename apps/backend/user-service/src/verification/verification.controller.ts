import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  Headers,
  Param,
  Post,
  Put,
  Query,
  UnauthorizedException,
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
  approveDriver(
    @Headers('x-user-role') authRole: string | undefined,
    @Param('userId') userId: string,
  ) {
    this.assertAdmin(authRole)
    return this.service.approveDriver(userId)
  }

  @Put('drivers/:userId/reject')
  rejectDriver(
    @Headers('x-user-role') authRole: string | undefined,
    @Param('userId') userId: string,
    @Body('reason') reason: string,
  ) {
    this.assertAdmin(authRole)
    return this.service.rejectDriver(userId, reason)
  }

  @Put('drivers/:userId/online')
  setOnline(@Param('userId') userId: string, @Body('isOnline') isOnline: boolean) {
    return this.service.setDriverOnline(userId, isOnline)
  }

  @Get('drivers/admin/pending')
  listPending(
    @Headers('x-user-role') authRole: string | undefined,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    this.assertAdmin(authRole)
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
  approveMerchant(
    @Headers('x-user-role') authRole: string | undefined,
    @Param('userId') userId: string,
  ) {
    this.assertAdmin(authRole)
    return this.service.approveMerchant(userId)
  }

  @Put('merchants/:userId/reject')
  rejectMerchant(
    @Headers('x-user-role') authRole: string | undefined,
    @Param('userId') userId: string,
    @Body('reason') reason: string,
  ) {
    this.assertAdmin(authRole)
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
  verifyDoc(
    @Headers('x-user-role') authRole: string | undefined,
    @Headers('x-user-id') adminId: string | undefined,
    @Param('docId') docId: string,
  ) {
    this.assertAdmin(authRole)
    this.assertAuthenticated(adminId)
    return this.service.verifyDocument(docId, adminId)
  }

  private assertAuthenticated(userId: string | undefined): asserts userId is string {
    if (!userId) {
      throw new UnauthorizedException('Missing authenticated user')
    }
  }

  private assertAdmin(authRole: string | undefined) {
    if (!authRole) {
      throw new UnauthorizedException('Missing admin role')
    }

    if (authRole !== 'ADMIN') {
      throw new ForbiddenException('Admin role required')
    }
  }
}
