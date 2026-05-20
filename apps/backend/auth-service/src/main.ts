import { initTracing } from '@crab/backend-shared'
import { NestFactory } from '@nestjs/core'
import { ValidationPipe, Logger } from '@nestjs/common'
import { AppModule } from './app.module'

async function bootstrap() {
  await initTracing({ serviceName: 'auth-service' })
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
  app.enableCors()
  app.enableShutdownHooks()

  const port = process.env.PORT ?? 3001
  await app.listen(port)
  logger.log(`Auth service running on port ${port}`)
}

bootstrap()
