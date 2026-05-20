import { CircuitBreaker, CircuitBreakerOpenError } from './circuit-breaker';

describe('CircuitBreaker', () => {
  let cb: CircuitBreaker;
  let nowSpy: jest.SpyInstance;
  let currentTime: number;

  beforeEach(() => {
    currentTime = 1000000;
    nowSpy = jest.spyOn(Date, 'now').mockImplementation(() => currentTime);
    cb = new CircuitBreaker('test-service', {
      timeoutMs: 1000,
      halfOpenAfterMs: 5000,
      errorThresholdPct: 50,
      volumeThreshold: 4,
      rollingWindowMs: 10000,
    });
  });

  afterEach(() => {
    nowSpy.mockRestore();
  });

  describe('CLOSED state', () => {
    it('starts in CLOSED state', () => {
      expect(cb.getState()).toBe('CLOSED');
    });

    it('allows successful calls through', async () => {
      const result = await cb.execute(() => Promise.resolve('ok'));
      expect(result).toBe('ok');
      expect(cb.getState()).toBe('CLOSED');
    });

    it('stays CLOSED when failures are below threshold', async () => {
      // 1 failure out of 4 = 25% < 50% threshold
      await cb.execute(() => Promise.resolve('ok'));
      await cb.execute(() => Promise.resolve('ok'));
      await cb.execute(() => Promise.resolve('ok'));
      await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow('fail');
      expect(cb.getState()).toBe('CLOSED');
    });

    it('stays CLOSED when volume is below volumeThreshold', async () => {
      // 3 failures but only 3 total calls < volumeThreshold of 4
      for (let i = 0; i < 3; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      expect(cb.getState()).toBe('CLOSED');
    });
  });

  describe('CLOSED -> OPEN transition', () => {
    it('trips OPEN when failure rate exceeds threshold with enough volume', async () => {
      // 4 failures out of 4 = 100% >= 50% threshold, volume=4 >= volumeThreshold=4
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      expect(cb.getState()).toBe('OPEN');
    });

    it('trips OPEN at exactly the threshold percentage', async () => {
      // 2 success + 2 failures = 50% failure rate, but need volume >= 4
      await cb.execute(() => Promise.resolve('ok'));
      await cb.execute(() => Promise.resolve('ok'));
      await expect(cb.execute(() => Promise.reject(new Error('f1')))).rejects.toThrow();
      await expect(cb.execute(() => Promise.reject(new Error('f2')))).rejects.toThrow();
      expect(cb.getState()).toBe('OPEN');
    });
  });

  describe('OPEN state behavior', () => {
    beforeEach(async () => {
      // Trip the breaker
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      expect(cb.getState()).toBe('OPEN');
    });

    it('throws CircuitBreakerOpenError without calling fn', async () => {
      const fn = jest.fn().mockResolvedValue('should not run');
      await expect(cb.execute(fn)).rejects.toThrow(CircuitBreakerOpenError);
      expect(fn).not.toHaveBeenCalled();
    });

    it('calls fallback when state is OPEN and fallback provided', async () => {
      const fn = jest.fn().mockResolvedValue('primary');
      const fallback = jest.fn().mockReturnValue('fallback-value');

      const result = await cb.execute(fn, fallback);
      expect(result).toBe('fallback-value');
      expect(fn).not.toHaveBeenCalled();
      expect(fallback).toHaveBeenCalledTimes(1);
    });
  });

  describe('OPEN -> HALF_OPEN transition', () => {
    beforeEach(async () => {
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      expect(cb.getState()).toBe('OPEN');
    });

    it('transitions to HALF_OPEN after cooldown period', async () => {
      // Advance time past halfOpenAfterMs (5000ms)
      currentTime += 5001;
      // Next call triggers transition to HALF_OPEN and executes
      const result = await cb.execute(() => Promise.resolve('probe'));
      expect(result).toBe('probe');
      // Successful probe transitions to CLOSED
      expect(cb.getState()).toBe('CLOSED');
    });

    it('stays OPEN before cooldown expires', async () => {
      currentTime += 4999; // Not yet past 5000ms cooldown
      await expect(cb.execute(() => Promise.resolve('x'))).rejects.toThrow(
        CircuitBreakerOpenError,
      );
      expect(cb.getState()).toBe('OPEN');
    });
  });

  describe('HALF_OPEN -> CLOSED on probe success', () => {
    it('transitions to CLOSED when probe call succeeds', async () => {
      // Trip breaker
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      expect(cb.getState()).toBe('OPEN');

      // Advance past cooldown
      currentTime += 5001;

      // Successful probe
      await cb.execute(() => Promise.resolve('recovered'));
      expect(cb.getState()).toBe('CLOSED');
    });

    it('resets records after transitioning to CLOSED', async () => {
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      currentTime += 5001;
      await cb.execute(() => Promise.resolve('ok'));

      const stats = cb.getStats();
      expect(stats.state).toBe('CLOSED');
      expect(stats.total).toBe(0);
    });
  });

  describe('HALF_OPEN -> OPEN on probe failure', () => {
    it('transitions back to OPEN when probe call fails', async () => {
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      expect(cb.getState()).toBe('OPEN');

      currentTime += 5001;

      // Failed probe
      await expect(cb.execute(() => Promise.reject(new Error('still broken')))).rejects.toThrow(
        'still broken',
      );
      expect(cb.getState()).toBe('OPEN');
    });

    it('calls fallback after probe failure trips back to OPEN', async () => {
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      currentTime += 5001;

      // Probe fails, breaker goes OPEN, fallback is called
      const fallback = jest.fn().mockReturnValue('fb');
      const result = await cb.execute(() => Promise.reject(new Error('nope')), fallback);
      expect(result).toBe('fb');
      expect(cb.getState()).toBe('OPEN');
    });
  });

  describe('HALF_OPEN only allows one probe at a time', () => {
    it('rejects concurrent calls while probe is in-flight', async () => {
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      currentTime += 5001;

      // Start a slow probe
      let resolveProbe: (v: string) => void;
      const probePromise = cb.execute(
        () => new Promise<string>((r) => { resolveProbe = r; }),
      );

      // Second call while probe in-flight should get fallback/error
      const fallback = jest.fn().mockReturnValue('queued');
      const secondResult = await cb.execute(() => Promise.resolve('x'), fallback);
      expect(secondResult).toBe('queued');
      expect(fallback).toHaveBeenCalled();

      // Resolve the probe
      resolveProbe!('done');
      const probeResult = await probePromise;
      expect(probeResult).toBe('done');
      expect(cb.getState()).toBe('CLOSED');
    });
  });

  describe('rolling window eviction', () => {
    it('evicts old records outside the rolling window', async () => {
      // Record 2 failures at t=1000000
      await expect(cb.execute(() => Promise.reject(new Error('f1')))).rejects.toThrow();
      await expect(cb.execute(() => Promise.reject(new Error('f2')))).rejects.toThrow();

      // Advance time past rolling window (10000ms)
      currentTime += 10001;

      // Now add 2 successes — old failures are evicted, so rate = 0%
      await cb.execute(() => Promise.resolve('ok'));
      await cb.execute(() => Promise.resolve('ok'));

      expect(cb.getState()).toBe('CLOSED');
      const stats = cb.getStats();
      expect(stats.failures).toBe(0);
      expect(stats.successes).toBe(2);
    });
  });

  describe('timeout handling', () => {
    it('rejects with CircuitBreakerTimeoutError when fn exceeds timeoutMs', async () => {
      const slowFn = () => new Promise<string>((resolve) => setTimeout(resolve, 5000, 'late'));
      await expect(cb.execute(slowFn)).rejects.toThrow('timed out after 1000ms');
    });
  });

  describe('manual reset', () => {
    it('resets state to CLOSED and clears records', async () => {
      for (let i = 0; i < 4; i++) {
        await expect(cb.execute(() => Promise.reject(new Error('fail')))).rejects.toThrow();
      }
      expect(cb.getState()).toBe('OPEN');

      cb.reset();
      expect(cb.getState()).toBe('CLOSED');
      expect(cb.getStats().total).toBe(0);
    });
  });
});
