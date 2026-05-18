import {
  All,
  Controller,
  Req,
  Res,
  Body,
  HttpException,
  Get,
} from '@nestjs/common'
import type { Request, Response } from 'express'
import { ProxyService, ServiceName } from './proxy.service'

@Controller()
export class ProxyController {
  constructor(private readonly proxy: ProxyService) {}

  @Get('proxy/health')
  health() {
    return {
      gateway: 'ok',
      circuits: this.proxy.getCircuitStatus(),
      timestamp: new Date().toISOString(),
    }
  }

  @All('auth/*')
  async auth(@Req() req: Request, @Res() res: Response, @Body() body: unknown) {
    return this.handle('auth', req, res, body)
  }

  @All('profiles/*')
  async profiles(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('user', req, res, body)
  }

  @All('addresses/*')
  async addresses(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('user', req, res, body)
  }

  @All('verification/*')
  async verification(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('user', req, res, body)
  }

  @All('rides/*')
  async rides(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('ride', req, res, body)
  }

  @All('drivers/*')
  async drivers(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('ride', req, res, body)
  }

  @All('restaurants/*')
  async restaurants(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('food', req, res, body)
  }

  @All('orders/*')
  async orders(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('food', req, res, body)
  }

  @All('menus/*')
  async menus(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('food', req, res, body)
  }

  @All('wallet/*')
  async wallet(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('payment', req, res, body)
  }

  @All('transactions/*')
  async transactions(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('payment', req, res, body)
  }

  @All('promo/*')
  async promo(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('payment', req, res, body)
  }

  @All('chats/*')
  async chats(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('chat', req, res, body)
  }

  @All('notifications/*')
  async notifications(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('notification', req, res, body)
  }

  @All('ratings/*')
  async ratings(
    @Req() req: Request,
    @Res() res: Response,
    @Body() body: unknown,
  ) {
    return this.handle('rating', req, res, body)
  }

  private async handle(
    service: ServiceName,
    req: Request,
    res: Response,
    body: unknown,
  ) {
    try {
      const path = req.path.replace(/^\/api\/v1/, '')
      const headers: Record<string, string> = {}
      if (req.headers.authorization) {
        headers['Authorization'] = req.headers.authorization as string
      }
      if (req.headers['x-user-id']) {
        headers['X-User-Id'] = req.headers['x-user-id'] as string
      }
      const data = await this.proxy.forward(
        service,
        req.method,
        path,
        body,
        headers,
      )
      res.json(data)
    } catch (err: unknown) {
      const e = err as {
        status?: number
        message?: string
        data?: unknown
      }
      if (e.status) {
        res.status(e.status).json({
          message: e.message,
          ...(typeof e.data === 'object' && e.data !== null
            ? (e.data as Record<string, unknown>)
            : {}),
        })
      } else if (err instanceof HttpException) {
        res.status(err.getStatus()).json(err.getResponse())
      } else {
        res.status(503).json({ message: 'Service unavailable' })
      }
    }
  }
}
