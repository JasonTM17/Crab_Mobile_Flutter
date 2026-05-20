import { diag, DiagConsoleLogger, DiagLogLevel } from '@opentelemetry/api';

let started = false;
let sdk: unknown;

export interface TracingOptions {
  /** Logical service name (resource.service.name). */
  serviceName: string;
  /** OTLP/HTTP collector endpoint. Defaults to env. */
  endpoint?: string;
  /** Service version, e.g. git SHA. */
  serviceVersion?: string;
  /** Deployment environment, e.g. "production". */
  environment?: string;
}

/**
 * Initialise OpenTelemetry tracing.
 *
 * MUST be called BEFORE `NestFactory.create(...)` so that auto-instrumentation
 * can patch `http`, `ioredis`, `pg`, `mongodb`, etc. before modules are loaded.
 *
 * No-op when neither `endpoint` nor `OTEL_EXPORTER_OTLP_ENDPOINT` is set:
 * keeps the dependency cost zero in environments without a collector.
 */
export async function initTracing(options: TracingOptions): Promise<void> {
  if (started) return;

  const endpoint =
    options.endpoint ??
    process.env.OTEL_EXPORTER_OTLP_ENDPOINT ??
    process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT;

  if (!endpoint) {
    // Tracing disabled by config absence; mark as "started" so callers can
    // be idempotent without inspecting env themselves.
    started = true;
    return;
  }

  if (process.env.OTEL_LOG_LEVEL === 'debug') {
    diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.DEBUG);
  }

  // Lazy require so that environments without OTel installed don't pay the
  // load cost simply by importing this module.
  /* eslint-disable @typescript-eslint/no-var-requires */
  const { NodeSDK } = await import('@opentelemetry/sdk-node');
  const { OTLPTraceExporter } = await import(
    '@opentelemetry/exporter-trace-otlp-http'
  );
  const { getNodeAutoInstrumentations } = await import(
    '@opentelemetry/auto-instrumentations-node'
  );
  /* eslint-enable @typescript-eslint/no-var-requires */

  const traceExporter = new OTLPTraceExporter({
    url: endpoint.endsWith('/v1/traces')
      ? endpoint
      : `${endpoint.replace(/\/$/, '')}/v1/traces`,
  });

  const node = new NodeSDK({
    serviceName: options.serviceName,
    traceExporter,
    instrumentations: [
      getNodeAutoInstrumentations({
        // fs is too noisy for production traces.
        '@opentelemetry/instrumentation-fs': { enabled: false },
        '@opentelemetry/instrumentation-http': { enabled: true },
        '@opentelemetry/instrumentation-ioredis': { enabled: true },
        '@opentelemetry/instrumentation-pg': { enabled: true },
        '@opentelemetry/instrumentation-mongodb': { enabled: true },
        '@opentelemetry/instrumentation-nestjs-core': { enabled: true },
      }),
    ],
  });

  sdk = node;
  node.start();
  started = true;

  process.once('SIGTERM', () => {
    node
      .shutdown()
      .catch((err) => console.error('OTel shutdown failed', err))
      .finally(() => process.exit(0));
  });
}

export function isTracingStarted(): boolean {
  return started;
}

/** Test-only helper to reset the singleton between tests. */
export function __resetTracingForTests(): void {
  started = false;
  sdk = undefined;
}
