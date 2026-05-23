import { initTracing } from '@crab/backend-shared'
import { ValidationPipe, Logger } from '@nestjs/common'
import { NestFactory } from '@nestjs/core'
import { AppModule } from './app.module'

function getCorsOrigins(): string[] {
  const raw = process.env.CORS_ORIGIN ?? process.env.CORS_ORIGINS
  if (raw != null && raw.trim().length > 0) {
    const origins = raw
      .split(',')
      .map((origin) => origin.trim())
      .filter((origin) => origin.length > 0)
    if (origins.length === 1 && origins[0] === '*') {
      throw new Error('Wildcard CORS is not allowed when credentials are enabled')
    }
    return origins
  }

  if ((process.env.NODE_ENV ?? 'development') === 'production') {
    throw new Error('CORS_ORIGIN is required in production')
  }

  return ['http://localhost:5173', 'http://localhost:3000']
}

async function bootstrap() {
  await initTracing({ serviceName: 'food-service' })
  const logger = new Logger('Bootstrap')
  const app = await NestFactory.create(AppModule)

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  )

  app.setGlobalPrefix('api/v1', {
    exclude: ['health', 'healthz', 'readyz', 'metrics'],
  })

  const corsOrigins = getCorsOrigins()
  app.enableCors({ origin: corsOrigins, credentials: true })
  logger.log(`Food Service CORS origins: ${corsOrigins.join(', ')}`)

  app.enableShutdownHooks()

  const port = process.env.PORT ?? 3004
  await app.listen(port)
  logger.log(`Food Service running on port ${port}`)
}

bootstrap()
