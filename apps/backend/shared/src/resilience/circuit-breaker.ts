import { Logger } from '@nestjs/common';

export type CircuitState = 'CLOSED' | 'OPEN' | 'HALF_OPEN';

export interface CircuitBreakerOptions {
  /** Operation timeout in ms. Default 3000. */
  timeoutMs?: number;
  /** Time to wait after opening before trying HALF_OPEN. Default 5000. */
  halfOpenAfterMs?: number;
  /** Percentage of failures (0-100) that trips OPEN. Default 50. */
  errorThresholdPct?: number;
  /** Min requests in window before threshold applies. Default 10. */
  volumeThreshold?: number;
  /** Rolling window size in ms. Default 10000. */
  rollingWindowMs?: number;
}

interface CallRecord {
  timestamp: number;
  success: boolean;
}

export class CircuitBreakerOpenError extends Error {
  public readonly code = 'CIRCUIT_OPEN';
  constructor(name: string) {
    super(`Circuit breaker [${name}] is OPEN`);
    this.name = 'CircuitBreakerOpenError';
  }
}

export class CircuitBreakerTimeoutError extends Error {
  public readonly code = 'CIRCUIT_TIMEOUT';
  constructor(name: string, ms: number) {
    super(`Circuit breaker [${name}] timed out after ${ms}ms`);
    this.name = 'CircuitBreakerTimeoutError';
  }
}

/**
 * In-house circuit breaker. No external dep.
 * Wraps an async function with timeout, error tracking, and rolling window.
 */
export class CircuitBreaker {
  private readonly logger: Logger;
  private readonly timeoutMs: number;
  private readonly halfOpenAfterMs: number;
  private readonly errorThresholdPct: number;
  private readonly volumeThreshold: number;
  private readonly rollingWindowMs: number;

  private state: CircuitState = 'CLOSED';
  private nextAttemptAt = 0;
  private records: CallRecord[] = [];
  private halfOpenInFlight = false;

  constructor(
    public readonly name: string,
    options: CircuitBreakerOptions = {},
  ) {
    this.logger = new Logger(`CircuitBreaker:${name}`);
    this.timeoutMs = options.timeoutMs ?? 3000;
    this.halfOpenAfterMs = options.halfOpenAfterMs ?? 5000;
    this.errorThresholdPct = options.errorThresholdPct ?? 50;
    this.volumeThreshold = options.volumeThreshold ?? 10;
    this.rollingWindowMs = options.rollingWindowMs ?? 10000;
  }

  getState(): CircuitState {
    return this.state;
  }

  getStats(): {
    state: CircuitState;
    total: number;
    failures: number;
    successes: number;
    failureRate: number;
  } {
    this.evictExpired();
    const total = this.records.length;
    const failures = this.records.filter((r) => !r.success).length;
    const successes = total - failures;
    const failureRate = total === 0 ? 0 : (failures / total) * 100;
    return { state: this.state, total, failures, successes, failureRate };
  }

  /**
   * Execute fn through the breaker. If OPEN, calls fallback or throws.
   */
  async execute<T>(fn: () => Promise<T>, fallback?: () => Promise<T> | T): Promise<T> {
    if (this.state === 'OPEN') {
      if (Date.now() >= this.nextAttemptAt) {
        this.transitionTo('HALF_OPEN');
      } else {
        return this.handleOpen(fallback);
      }
    }

    if (this.state === 'HALF_OPEN' && this.halfOpenInFlight) {
      return this.handleOpen(fallback);
    }

    if (this.state === 'HALF_OPEN') {
      this.halfOpenInFlight = true;
    }

    try {
      const result = await this.invokeWithTimeout(fn);
      this.onSuccess();
      return result;
    } catch (err) {
      this.onFailure(err);
      if (this.state === 'OPEN' && fallback) {
        return await fallback();
      }
      throw err;
    } finally {
      this.halfOpenInFlight = false;
    }
  }

  private async handleOpen<T>(fallback?: () => Promise<T> | T): Promise<T> {
    if (fallback) {
      return await fallback();
    }
    throw new CircuitBreakerOpenError(this.name);
  }

  private invokeWithTimeout<T>(fn: () => Promise<T>): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      const timer = setTimeout(() => {
        reject(new CircuitBreakerTimeoutError(this.name, this.timeoutMs));
      }, this.timeoutMs);

      Promise.resolve()
        .then(fn)
        .then(
          (val) => {
            clearTimeout(timer);
            resolve(val);
          },
          (err) => {
            clearTimeout(timer);
            reject(err);
          },
        );
    });
  }

  private onSuccess(): void {
    this.recordCall(true);
    if (this.state === 'HALF_OPEN') {
      this.transitionTo('CLOSED');
      this.records = [];
    }
  }

  private onFailure(err: unknown): void {
    this.recordCall(false);
    this.logger.warn(
      `Call failed (state=${this.state}): ${(err as Error)?.message ?? 'unknown'}`,
    );

    if (this.state === 'HALF_OPEN') {
      this.transitionTo('OPEN');
      return;
    }

    if (this.shouldTrip()) {
      this.transitionTo('OPEN');
    }
  }

  private shouldTrip(): boolean {
    this.evictExpired();
    const total = this.records.length;
    if (total < this.volumeThreshold) return false;
    const failures = this.records.filter((r) => !r.success).length;
    const rate = (failures / total) * 100;
    return rate >= this.errorThresholdPct;
  }

  private recordCall(success: boolean): void {
    this.records.push({ timestamp: Date.now(), success });
    this.evictExpired();
  }

  private evictExpired(): void {
    const cutoff = Date.now() - this.rollingWindowMs;
    while (this.records.length > 0 && this.records[0].timestamp < cutoff) {
      this.records.shift();
    }
  }

  private transitionTo(next: CircuitState): void {
    if (this.state === next) return;
    const prev = this.state;
    this.state = next;
    if (next === 'OPEN') {
      this.nextAttemptAt = Date.now() + this.halfOpenAfterMs;
    }
    this.logger.log(`State: ${prev} -> ${next}`);
  }

  /** Manual reset (e.g. for tests or admin endpoint). */
  reset(): void {
    this.records = [];
    this.halfOpenInFlight = false;
    this.transitionTo('CLOSED');
  }
}
