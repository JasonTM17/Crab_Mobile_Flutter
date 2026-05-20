import { Injectable, Logger } from '@nestjs/common';
import { CircuitBreaker, CircuitBreakerOptions } from './circuit-breaker';

/**
 * Registry that returns shared CircuitBreaker instances keyed by name.
 *
 * Use one instance per logical dependency (e.g. "user-service",
 * "stripe-charges") so the rolling window aggregates calls from all
 * call-sites of that dependency.
 */
@Injectable()
export class CircuitBreakerFactory {
  private readonly logger = new Logger(CircuitBreakerFactory.name);
  private readonly registry = new Map<string, CircuitBreaker>();

  /**
   * Get-or-create a breaker by name. Options apply only on first creation;
   * subsequent calls return the existing instance.
   */
  get(name: string, options?: CircuitBreakerOptions): CircuitBreaker {
    let breaker = this.registry.get(name);
    if (!breaker) {
      breaker = new CircuitBreaker(name, options);
      this.registry.set(name, breaker);
      this.logger.log(`Created circuit breaker [${name}]`);
    }
    return breaker;
  }

  /** Convenience: execute through a named breaker. */
  async execute<T>(
    name: string,
    fn: () => Promise<T>,
    fallback?: () => Promise<T> | T,
    options?: CircuitBreakerOptions,
  ): Promise<T> {
    return this.get(name, options).execute(fn, fallback);
  }

  /** Snapshot all breaker stats for a /health endpoint. */
  snapshot(): Record<string, ReturnType<CircuitBreaker['getStats']>> {
    const out: Record<string, ReturnType<CircuitBreaker['getStats']>> = {};
    for (const [name, breaker] of this.registry.entries()) {
      out[name] = breaker.getStats();
    }
    return out;
  }

  /** Reset every breaker (e.g. admin endpoint, integration tests). */
  resetAll(): void {
    for (const breaker of this.registry.values()) {
      breaker.reset();
    }
  }

  has(name: string): boolean {
    return this.registry.has(name);
  }
}
