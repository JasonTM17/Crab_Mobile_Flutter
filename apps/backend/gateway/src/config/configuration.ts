export default () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),
  jwtSecret: process.env.JWT_SECRET ?? 'change-me-in-production',
  corsOrigin: process.env.CORS_ORIGIN ?? '*',
  redis: {
    host: process.env.REDIS_HOST ?? 'localhost',
    port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
  },
  services: {
    authUrl: process.env.AUTH_SERVICE_URL ?? 'http://localhost:3001',
    userUrl: process.env.USER_SERVICE_URL ?? 'http://localhost:3002',
  },
  throttle: {
    ttl: parseInt(process.env.THROTTLE_TTL ?? '60000', 10),
    limit: parseInt(process.env.THROTTLE_LIMIT ?? '100', 10),
  },
})
