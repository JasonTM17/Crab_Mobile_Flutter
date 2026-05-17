import { Injectable } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import * as Minio from 'minio'
import { v4 as uuidv4 } from 'uuid'

@Injectable()
export class MinioService {
  private readonly client: Minio.Client
  private readonly bucket: string

  constructor(private readonly config: ConfigService) {
    this.client = new Minio.Client({
      endPoint: config.get('MINIO_ENDPOINT', 'localhost'),
      port: config.get<number>('MINIO_PORT', 9000),
      useSSL: config.get('MINIO_USE_SSL', 'false') === 'true',
      accessKey: config.get('MINIO_ROOT_USER', 'crab_minio'),
      secretKey: config.get('MINIO_ROOT_PASSWORD', 'crab_minio_secret'),
    })
    this.bucket = config.get('MINIO_BUCKET', 'crab-uploads')
  }

  async ensureBucket(): Promise<void> {
    const exists = await this.client.bucketExists(this.bucket)
    if (!exists) {
      await this.client.makeBucket(this.bucket, 'us-east-1')
    }
  }

  async uploadAvatar(userId: string, buffer: Buffer, mimeType: string): Promise<string> {
    await this.ensureBucket()
    const ext = mimeType.split('/')[1] ?? 'jpg'
    const objectName = `avatars/${userId}/${uuidv4()}.${ext}`
    await this.client.putObject(this.bucket, objectName, buffer, buffer.length, {
      'Content-Type': mimeType,
    })
    const endpoint = this.config.get('MINIO_ENDPOINT', 'localhost')
    const port = this.config.get<number>('MINIO_PORT', 9000)
    const useSSL = this.config.get('MINIO_USE_SSL', 'false') === 'true'
    const protocol = useSSL ? 'https' : 'http'
    return `${protocol}://${endpoint}:${port}/${this.bucket}/${objectName}`
  }

  async deleteObject(objectUrl: string): Promise<void> {
    try {
      const url = new URL(objectUrl)
      const objectName = url.pathname.replace(`/${this.bucket}/`, '')
      await this.client.removeObject(this.bucket, objectName)
    } catch {}
  }
}
