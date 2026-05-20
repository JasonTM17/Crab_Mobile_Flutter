import { initTracing } from '@crab/backend-shared'
import { NestFactory } from '@nestjs/core'
import { ValidationPipe, Logger } from '@nestjs/common'
import helmet from 'helmet'
import { AppModule } from './app.module'
import { HttpExceptionFilter } from './common/filters/http-exception.filter'
import { RedisIoAdapter } from './common/adapters/redis-io.adapter'

async function bootstrap() {
  await initTracing({ serviceName: 'gateway' })
  const logger = new Logger('Bootstrap')
  const app = await NestFactory.create(AppModule, {
    bodyParser: true,
    logger: ['error', 'warn', 'log'],
  })

  app.use(
    helmet({
      contentSecurityPolicy: false, // disable for WebSocket
    }),
  )

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false, // gateway pass-through, less strict
      transform: true,
    }),
  )

  app.useGlobalFilters(new HttpExceptionFilter())

  app.setGlobalPrefix('api/v1', { exclude: ['health', 'healthz', 'readyz', 'metrics'] })
  app.enableCors({
    origin: process.env.CORS_ORIGIN?.split(',') ?? '*',
    credentials: true,
  })

  // Redis adapter for Socket.IO multi-instance scaling
  const redisAdapter = new RedisIoAdapter(app)
  await redisAdapter.connectToRedis()
  app.useWebSocketAdapter(redisAdapter)

  // Graceful shutdown
  app.enableShutdownHooks()

  const port = process.env.PORT ?? 3000
  await app.listen(port)
  logger.log(`Gateway running on port ${port}`)
}

bootstrap()
