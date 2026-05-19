import { Injectable, Logger, OnModuleInit } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'

let admin: typeof import('firebase-admin') | null = null

@Injectable()
export class FcmService implements OnModuleInit {
  private readonly logger = new Logger(FcmService.name)
  private app: import('firebase-admin').app.App | null = null

  constructor(private readonly config: ConfigService) {}

  async onModuleInit() {
    const projectId = this.config.get<string>('FCM_PROJECT_ID')
    const credentialsJson = this.config.get<string>('FCM_CREDENTIALS_JSON')
    if (!projectId || !credentialsJson) {
      this.logger.warn('FCM not configured (FCM_PROJECT_ID or FCM_CREDENTIALS_JSON missing) — falling back to log-only mode')
      return
    }
    try {
      // Lazy import keeps the dep optional in dev/test
      admin = (await import('firebase-admin')).default
      const credential = admin.credential.cert(JSON.parse(credentialsJson))
      this.app = admin.initializeApp({ credential, projectId }, 'crab-notifications')
      this.logger.log(`FCM initialized for project ${projectId}`)
    } catch (err) {
      this.logger.error(`FCM init failed: ${(err as Error).message}`)
    }
  }

  async sendToTokens(
    tokens: string[],
    notification: { title: string; body: string; imageUrl?: string },
    data?: Record<string, string>,
  ): Promise<{ successCount: number; failureCount: number; invalidTokens: string[] }> {
    if (!this.app || !admin || tokens.length === 0) {
      this.logger.debug(`[FCM] Skipped (not initialized or no tokens): ${tokens.length} tokens`)
      return { successCount: 0, failureCount: 0, invalidTokens: [] }
    }
    try {
      const messaging = admin.messaging(this.app)
      const res = await messaging.sendEachForMulticast({
        tokens,
        notification,
        data,
      })
      const invalidTokens: string[] = []
      res.responses.forEach((r, i) => {
        if (!r.success && r.error) {
          const code = r.error.code
          if (
            code === 'messaging/invalid-registration-token' ||
            code === 'messaging/registration-token-not-registered'
          ) {
            invalidTokens.push(tokens[i])
          }
        }
      })
      return {
        successCount: res.successCount,
        failureCount: res.failureCount,
        invalidTokens,
      }
    } catch (err) {
      this.logger.error(`FCM send failed: ${(err as Error).message}`)
      return { successCount: 0, failureCount: tokens.length, invalidTokens: [] }
    }
  }
}
