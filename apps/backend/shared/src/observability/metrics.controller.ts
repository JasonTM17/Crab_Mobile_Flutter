import { Controller, Get, Header, Res } from '@nestjs/common';
import { Response } from 'express';
import { register } from 'prom-client';

/**
 * Exposes Prometheus metrics on `GET /metrics`.
 *
 * Mounted at the root of the application (no `api/v1` prefix) so scrapers
 * can hit it directly. Use `app.setGlobalPrefix('api/v1', { exclude: ['metrics'] })`
 * during bootstrap.
 */
@Controller('metrics')
export class MetricsController {
  @Get()
  @Header('Content-Type', register.contentType)
  async metrics(@Res() res: Response): Promise<void> {
    const body = await register.metrics();
    res.status(200).send(body);
  }
}
