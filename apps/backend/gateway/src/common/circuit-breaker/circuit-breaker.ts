import { Logger } from '@nestjs/common'

export enum CircuitState {
  CLOSED = 'CLOSED',
  OPEN = 'OPEN',
  HALF_OPEN = 'HALF_OPEN',
}

export interface CircuitBreakerOptions {
  failureThreshold: number
  successThreshold: number
  timeout: number // ms - time in OPEN state before trying HALF_OPEN
  resetTimeout: number // ms - request timeout
}

export class CircuitBreaker {
  private readonly logger = new Logger(CircuitBreaker.name)
  private state: CircuitState = CircuitState.CLOSED
  private failures = 0
  private successes = 0
  private nextAttempt = 0

  constructor(
    private readonly name: string,
    private readonly options: CircuitBreakerOptions = {
      failureThreshold: 5,
      successThreshold: 2,
      timeout: 30000,
      resetTimeout: 10000,
    },
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === CircuitState.OPEN) {
      if (Date.now() < this.nextAttempt) {
        throw new Error(`Circuit breaker OPEN for ${this.name}`)
      }
      this.state = CircuitState.HALF_OPEN
      this.successes = 0
      this.logger.warn(`Circuit ${this.name} -> HALF_OPEN`)
    }

    try {
      const result = await this.withTimeout(fn(), this.options.resetTimeout)
      this.onSuccess()
      return result
    } catch (err) {
      this.onFailure()
      throw err
    }
  }

  private withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
    return Promise.race([
      promise,
      new Promise<T>((_, reject) =>
        setTimeout(() => reject(new Error('Request timeout')), ms),
      ),
    ])
  }

  private onSuccess(): void {
    this.failures = 0
    if (this.state === CircuitState.HALF_OPEN) {
      this.successes++
      if (this.successes >= this.options.successThreshold) {
        this.state = CircuitState.CLOSED
        this.logger.log(`Circuit ${this.name} -> CLOSED`)
      }
    }
  }

  private onFailure(): void {
    this.failures++
    if (
      this.state === CircuitState.HALF_OPEN ||
      this.failures >= this.options.failureThreshold
    ) {
      this.state = CircuitState.OPEN
      this.nextAttempt = Date.now() + this.options.timeout
      this.logger.warn(
        `Circuit ${this.name} -> OPEN until ${new Date(this.nextAttempt).toISOString()}`,
      )
    }
  }

  getState(): CircuitState {
    return this.state
  }
}
