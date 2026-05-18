export default () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),
  jwtSecret: process.env.JWT_SECRET ?? 'change-me-in-production',
  corsOrigin: process.env.CORS_ORIGIN ?? '*',
  redis: {
    url: process.env.REDIS_URL ?? 'redis://localhost:6379',
    host: process.env.REDIS_HOST ?? 'localhost',
    port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
  },
  services: {
    authUrl: process.env.AUTH_SERVICE_URL ?? 'http://localhost:3001',
    userUrl: process.env.USER_SERVICE_URL ?? 'http://localhost:3002',
    rideUrl: process.env.RIDE_SERVICE_URL ?? 'http://localhost:3003',
    foodUrl: process.env.FOOD_SERVICE_URL ?? 'http://localhost:3004',
    paymentUrl: process.env.PAYMENT_SERVICE_URL ?? 'http://localhost:3005',
    chatUrl: process.env.CHAT_SERVICE_URL ?? 'http://localhost:3006',
    notificationUrl:
      process.env.NOTIFICATION_SERVICE_URL ?? 'http://localhost:3007',
    ratingUrl: process.env.RATING_SERVICE_URL ?? 'http://localhost:3008',
  },
  throttle: {
    ttl: parseInt(process.env.THROTTLE_TTL ?? '60000', 10),
    limit: parseInt(process.env.THROTTLE_LIMIT ?? '100', 10),
  },
})
