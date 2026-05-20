import {
  Inject,
  Injectable,
  Logger,
  Optional,
  OnApplicationBootstrap,
  OnModuleDestroy,
} from '@nestjs/common';

export const SHUTDOWN_HOOKS_TOKEN = 'GRACEFUL_SHUTDOWN_HOOKS';

export type ShutdownHook = () => Promise<void> | void;

export interface NamedShutdownHook {
  name: string;
  /** Lower runs first. Default 100. */
  order?: number;
  fn: ShutdownHook;
}

export interface GracefulShutdownConfig {
  /** Hard deadline before process.exit. Default 30000ms. */
  graceMs?: number;
  /** Hooks injected statically at module registration time. */
  hooks?: NamedShutdownHook[];
}

/**
 * Drain in-flight work on SIGTERM/SIGINT.
 *
 * Standard hook order recipe:
 *   10  - flip readiness probe to "draining"
 *   20  - close HTTP server (stop accepting new requests)
 *   30  - close Socket.IO server
 *   40  - drain BullMQ queues / workers
 *   50  - close DB connections (Postgres, Mongo)
 *   60  - close Redis connection(s)
 */
@Injectable()
export class GracefulShutdownService implements OnApplicationBootstrap, OnModuleDestroy {
  private readonly logger = new Logger(GracefulShutdownService.name);
  private readonly hooks: NamedShutdownHook[] = [];
  private readonly graceMs: number;
  private signalsBound = false;
  private shuttingDown = false;

  constructor(
    @Optional() @Inject(SHUTDOWN_HOOKS_TOKEN) staticHooks?: NamedShutdownHook[],
    @Optional() config?: GracefulShutdownConfig,
  ) {
    this.graceMs = config?.graceMs ?? 30_000;
    if (staticHooks?.length) this.hooks.push(...staticHooks);
    if (config?.hooks?.length) this.hooks.push(...config.hooks);
  }

  /** Register a hook at runtime (e.g. from feature modules during bootstrap). */
  register(hook: NamedShutdownHook): void {
    this.hooks.push(hook);
  }

  onApplicationBootstrap(): void {
    if (this.signalsBound) return;
    this.signalsBound = true;

    const onSignal = (signal: NodeJS.Signals) => {
      if (this.shuttingDown) return;
      this.logger.warn(`Received ${signal}, starting graceful shutdown...`);
      void this.runShutdown().then(() => {
        process.exit(0);
      });
    };

    process.on('SIGTERM', onSignal);
    process.on('SIGINT', onSignal);
    this.logger.log(`Bound SIGTERM/SIGINT handlers (grace=${this.graceMs}ms)`);
  }

  /**
   * Nest module-destroy hook. Runs the same drain when Nest closes the app
   * (e.g. integration tests, programmatic close).
   */
  async onModuleDestroy(): Promise<void> {
    if (this.shuttingDown) return;
    await this.runShutdown();
  }

  private async runShutdown(): Promise<void> {
    this.shuttingDown = true;
    const start = Date.now();

    const ordered = [...this.hooks].sort(
      (a, b) => (a.order ?? 100) - (b.order ?? 100),
    );

    const drain = (async () => {
      for (const hook of ordered) {
        const hookStart = Date.now();
        try {
          await hook.fn();
          this.logger.log(
            `Hook [${hook.name}] done in ${Date.now() - hookStart}ms`,
          );
        } catch (err) {
          this.logger.error(
            `Hook [${hook.name}] failed: ${(err as Error).message}`,
          );
        }
      }
    })();

    const deadline = new Promise<void>((resolve) => {
      const t = setTimeout(() => {
        this.logger.error(
          `Grace period (${this.graceMs}ms) exceeded; forcing shutdown.`,
        );
        resolve();
      }, this.graceMs);
      // Allow Node to exit even if timer is still scheduled.
      t.unref?.();
    });

    await Promise.race([drain, deadline]);
    this.logger.log(`Shutdown complete in ${Date.now() - start}ms`);
  }
}
