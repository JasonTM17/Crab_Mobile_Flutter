import { ExecutionContext, HttpException, HttpStatus } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { RedisRateLimitGuard, RateLimitOptions, RATE_LIMIT_METADATA } from './redis-rate-limit.guard';

describe('RedisRateLimitGuard', () => {
  let guard: RedisRateLimitGuard;
  let mockRedis: { eval: jest.Mock };
  let mockReflector: { getAllAndOverride: jest.Mock };
  let mockContext: ExecutionContext;
  let mockRequest: Record<string, any>;

  const defaultOptions: RateLimitOptions = {
    limit: 10,
    windowMs: 60000,
    keyBy: 'ip',
    bucket: 'test-bucket',
  };

  beforeEach(() => {
    mockRedis = { eval: jest.fn() };
    mockReflector = { getAllAndOverride: jest.fn() };

    mockRequest = {
      headers: {},
      ip: '192.168.1.1',
      socket: { remoteAddress: '10.0.0.1' },
    };

    mockContext = {
      switchToHttp: () => ({
        getRequest: () => mockRequest,
      }),
      getHandler: () => ({ name: 'testHandler' }),
      getClass: () => ({ name: 'TestController' }),
    } as unknown as ExecutionContext;

    guard = new RedisRateLimitGuard(
      mockRedis as any,
      mockReflector as unknown as Reflector,
    );
  });

  describe('when no rate limit metadata is set', () => {
    it('allows the request through', async () => {
      mockReflector.getAllAndOverride.mockReturnValue(undefined);
      const result = await guard.canActivate(mockContext);
      expect(result).toBe(true);
      expect(mockRedis.eval).not.toHaveBeenCalled();
    });
  });

  describe('when count is within limit', () => {
    it('allows the request through', async () => {
      mockReflector.getAllAndOverride.mockReturnValue(defaultOptions);
      mockRedis.eval.mockResolvedValue([5, 55000]); // count=5, ttl=55s

      const result = await guard.canActivate(mockContext);
      expect(result).toBe(true);
    });

    it('allows request at exactly the limit', async () => {
      mockReflector.getAllAndOverride.mockReturnValue(defaultOptions);
      mockRedis.eval.mockResolvedValue([10, 30000]); // count=10 == limit

      const result = await guard.canActivate(mockContext);
      expect(result).toBe(true);
    });
  });

  describe('when count exceeds limit', () => {
    it('throws HttpException with status 429', async () => {
      mockReflector.getAllAndOverride.mockReturnValue(defaultOptions);
      mockRedis.eval.mockResolvedValue([11, 45000]); // count=11 > limit=10

      await expect(guard.canActivate(mockContext)).rejects.toThrow(HttpException);
      try {
        await guard.canActivate(mockContext);
      } catch (e) {
        expect((e as HttpException).getStatus()).toBe(HttpStatus.TOO_MANY_REQUESTS);
      }
    });

    it('includes correct retryAfter in seconds (ceiling)', async () => {
      mockReflector.getAllAndOverride.mockReturnValue(defaultOptions);
      mockRedis.eval.mockResolvedValue([15, 3500]); // ttl=3500ms -> ceil(3.5)=4s

      try {
        await guard.canActivate(mockContext);
      } catch (e) {
        const body = (e as HttpException).getResponse() as Record<string, unknown>;
        expect(body.retryAfter).toBe(4);
      }
    });

    it('returns retryAfter minimum of 1 second', async () => {
      mockReflector.getAllAndOverride.mockReturnValue(defaultOptions);
      mockRedis.eval.mockResolvedValue([20, 100]); // ttl=100ms -> ceil(0.1)=1 (max(1,...))

      try {
        await guard.canActivate(mockContext);
      } catch (e) {
        const body = (e as HttpException).getResponse() as Record<string, unknown>;
        expect(body.retryAfter).toBe(1);
      }
    });
  });

  describe('fail-open when Redis throws', () => {
    it('returns true and does not block the request', async () => {
      mockReflector.getAllAndOverride.mockReturnValue(defaultOptions);
      mockRedis.eval.mockRejectedValue(new Error('ECONNREFUSED'));

      const result = await guard.canActivate(mockContext);
      expect(result).toBe(true);
    });
  });

  describe('deriveActor with keyBy=ip', () => {
    beforeEach(() => {
      mockReflector.getAllAndOverride.mockReturnValue(defaultOptions);
      mockRedis.eval.mockResolvedValue([1, 60000]);
    });

    it('uses X-Forwarded-For first entry when present', async () => {
      mockRequest.headers['x-forwarded-for'] = '203.0.113.50, 70.41.3.18';
      await guard.canActivate(mockContext);

      const evalCall = mockRedis.eval.mock.calls[0];
      const key = evalCall[2]; // KEYS[1]
      expect(key).toBe('rl:test-bucket:203.0.113.50');
    });

    it('falls back to req.ip when no X-Forwarded-For', async () => {
      mockRequest.headers = {};
      mockRequest.ip = '10.20.30.40';
      await guard.canActivate(mockContext);

      const key = mockRedis.eval.mock.calls[0][2];
      expect(key).toBe('rl:test-bucket:10.20.30.40');
    });

    it('falls back to socket.remoteAddress when req.ip is empty', async () => {
      mockRequest.headers = {};
      mockRequest.ip = '';
      mockRequest.socket = { remoteAddress: '172.16.0.5' };
      await guard.canActivate(mockContext);

      const key = mockRedis.eval.mock.calls[0][2];
      expect(key).toBe('rl:test-bucket:172.16.0.5');
    });

    it('uses "unknown" when no IP source available', async () => {
      mockRequest.headers = {};
      mockRequest.ip = '';
      mockRequest.socket = {};
      await guard.canActivate(mockContext);

      const key = mockRedis.eval.mock.calls[0][2];
      expect(key).toBe('rl:test-bucket:unknown');
    });
  });

  describe('deriveActor with keyBy=user', () => {
    it('uses user.id from request', async () => {
      const opts: RateLimitOptions = { ...defaultOptions, keyBy: 'user' };
      mockReflector.getAllAndOverride.mockReturnValue(opts);
      mockRedis.eval.mockResolvedValue([1, 60000]);
      mockRequest.user = { id: 'user-123' };

      await guard.canActivate(mockContext);
      const key = mockRedis.eval.mock.calls[0][2];
      expect(key).toBe('rl:test-bucket:user-123');
    });

    it('uses user.sub as fallback when id is missing', async () => {
      const opts: RateLimitOptions = { ...defaultOptions, keyBy: 'user' };
      mockReflector.getAllAndOverride.mockReturnValue(opts);
      mockRedis.eval.mockResolvedValue([1, 60000]);
      mockRequest.user = { sub: 'sub-456' };

      await guard.canActivate(mockContext);
      const key = mockRedis.eval.mock.calls[0][2];
      expect(key).toBe('rl:test-bucket:sub-456');
    });

    it('allows through when user is not authenticated (actor=null)', async () => {
      const opts: RateLimitOptions = { ...defaultOptions, keyBy: 'user' };
      mockReflector.getAllAndOverride.mockReturnValue(opts);
      mockRequest.user = undefined;

      const result = await guard.canActivate(mockContext);
      expect(result).toBe(true);
      expect(mockRedis.eval).not.toHaveBeenCalled();
    });
  });
});
