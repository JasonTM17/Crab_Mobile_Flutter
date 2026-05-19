import { NestFactory } from '@nestjs/core'
import { ValidationPipe } from '@nestjs/common'
import { AppModule } from './app.module'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }))
  app.setGlobalPrefix('api/v1', { exclude: ['health', 'metrics'] })
  app.enableCors({ origin: '*', credentials: true })
  const port = process.env.PORT ?? 3008
  await app.listen(port)
  console.log(`Rating Service running on port ${port}`)
}
bootstrap()
