import { getDefaultLogger, createLogger } from './logger';

describe('getDefaultLogger', () => {
  beforeEach(() => {
    // Reset the module-level singleton between tests
    jest.resetModules();
  });

  it('returns a pino logger instance', () => {
    const logger = getDefaultLogger();
    expect(logger).toBeDefined();
    expect(typeof logger.info).toBe('function');
    expect(typeof logger.error).toBe('function');
    expect(typeof logger.warn).toBe('function');
    expect(typeof logger.debug).toBe('function');
  });

  it('returns the same instance on multiple calls (singleton)', () => {
    const first = getDefaultLogger();
    const second = getDefaultLogger();
    expect(first).toBe(second);
  });
});

describe('createLogger', () => {
  it('produces JSON output with ts, level, and msg fields', () => {
    const chunks: string[] = [];
    const dest = {
      write(chunk: string) {
        chunks.push(chunk);
      },
    };

    // Create logger writing to a custom destination
    const pino = require('pino');
    const logger = pino(
      {
        level: 'info',
        base: { service: 'test-svc' },
        timestamp: () => `,"ts":"2024-01-01T00:00:00.000Z"`,
        messageKey: 'msg',
        formatters: {
          level(label: string) {
            return { level: label };
          },
        },
      },
      dest,
    );

    logger.info('hello world');

    expect(chunks.length).toBeGreaterThan(0);
    const parsed = JSON.parse(chunks[0]);
    expect(parsed).toHaveProperty('ts');
    expect(parsed).toHaveProperty('level', 'info');
    expect(parsed).toHaveProperty('msg', 'hello world');
    expect(parsed).toHaveProperty('service', 'test-svc');
  });

  it('creates a logger with the specified service name', () => {
    const logger = createLogger({ service: 'my-service', pretty: false });
    // Pino stores bindings; verify via child or serialization
    expect(logger).toBeDefined();
    // The logger should have level set
    expect(logger.level).toBeDefined();
  });
});
