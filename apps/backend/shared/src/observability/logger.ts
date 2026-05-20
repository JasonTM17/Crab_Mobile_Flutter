import pino, { Logger, LoggerOptions } from 'pino';

/**
 * Standard log field names used across all backend services.
 * Keep this list aligned with rule #12 (universal observability stack).
 */
export const LOG_FIELDS = {
  ts: 'ts',
  level: 'level',
  msg: 'msg',
  requestId: 'request_id',
  userId: 'user_id',
  route: 'route',
  latencyMs: 'latency_ms',
  status: 'status',
  service: 'service',
  traceId: 'trace_id',
  spanId: 'span_id',
} as const;

export interface CrabLoggerOptions {
  /** Logical service name, e.g. "auth-service". */
  service: string;
  /** Override log level. Defaults to env LOG_LEVEL or "info". */
  level?: string;
  /** Force pretty / json mode. Defaults to env-based detection. */
  pretty?: boolean;
}

/**
 * Build a pino logger configured for Crab backend services.
 *
 * - JSON output in production (NODE_ENV=production) or when pretty=false.
 * - Pretty output in dev when stdout is a TTY.
 * - ISO-8601 timestamps under field `ts`.
 * - Standard field names enforced via formatters and base fields.
 */
export function createLogger(opts: CrabLoggerOptions): Logger {
  const isProd = process.env.NODE_ENV === 'production';
  const level = opts.level ?? process.env.LOG_LEVEL ?? (isProd ? 'info' : 'debug');
  const pretty =
    opts.pretty ?? (!isProd && (process.stdout as NodeJS.WriteStream).isTTY === true);

  const baseOptions: LoggerOptions = {
    level,
    base: {
      service: opts.service,
    },
    timestamp: () => `,"ts":"${new Date().toISOString()}"`,
    messageKey: 'msg',
    formatters: {
      level(label) {
        return { level: label };
      },
    },
    redact: {
      paths: [
        'req.headers.authorization',
        'req.headers.cookie',
        'req.headers["x-api-key"]',
        'res.headers["set-cookie"]',
        '*.password',
        '*.token',
        '*.refresh_token',
        '*.access_token',
      ],
      censor: '[REDACTED]',
    },
  };

  if (pretty) {
    return pino({
      ...baseOptions,
      transport: {
        target: 'pino-pretty',
        options: {
          colorize: true,
          translateTime: 'SYS:standard',
          ignore: 'pid,hostname,service',
          singleLine: false,
        },
      },
    });
  }

  return pino(baseOptions);
}

/** Lazily-created shared logger when callers don't bring their own. */
let _defaultLogger: Logger | undefined;

export function getDefaultLogger(): Logger {
  if (!_defaultLogger) {
    _defaultLogger = createLogger({
      service: process.env.SERVICE_NAME ?? 'crab-backend',
    });
  }
  return _defaultLogger;
}

export type { Logger } from 'pino';
