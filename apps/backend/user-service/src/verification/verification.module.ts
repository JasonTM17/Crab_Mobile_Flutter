import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { VerificationController } from './verification.controller'
import { VerificationService } from './verification.service'
import { DriverProfileEntity } from './entities/driver-profile.entity'
import { MerchantProfileEntity } from './entities/merchant-profile.entity'
import { VerificationDocEntity } from './entities/verification-doc.entity'

@Module({
  imports: [
    TypeOrmModule.forFeature([
      DriverProfileEntity,
      MerchantProfileEntity,
      VerificationDocEntity,
    ]),
  ],
  controllers: [VerificationController],
  providers: [VerificationService],
  exports: [VerificationService],
})
export class VerificationModule {}
