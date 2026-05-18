import { Module } from '@nestjs/common'
import { HttpModule } from '@nestjs/axios'
import { ProxyService } from './proxy.service'
import { AuthProxyController, UserProxyController } from './proxy.controller'

@Module({
  imports: [HttpModule],
  controllers: [AuthProxyController, UserProxyController],
  providers: [ProxyService],
  exports: [ProxyService],
})
export class ProxyModule {}
