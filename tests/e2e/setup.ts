import { GenericContainer, StartedTestContainer } from 'testcontainers';

let postgresContainer: StartedTestContainer;
let mongoContainer: StartedTestContainer;
let redisContainer: StartedTestContainer;

export default async function setup() {
  console.log('\nStarting test containers...');

  [postgresContainer, mongoContainer, redisContainer] = await Promise.all([
    new GenericContainer('postgres:15-alpine')
      .withEnvironment({
        POSTGRES_USER: 'crab',
        POSTGRES_PASSWORD: 'crab',
        POSTGRES_DB: 'crab_test',
      })
      .withExposedPorts(5432)
      .start(),

    new GenericContainer('mongo:7')
      .withEnvironment({
        MONGO_INITDB_ROOT_USERNAME: 'crab',
        MONGO_INITDB_ROOT_PASSWORD: 'crab',
      })
      .withExposedPorts(27017)
      .start(),

    new GenericContainer('redis:7-alpine').withExposedPorts(6379).start(),
  ]);

  process.env.DATABASE_URL = `postgresql://crab:crab@${postgresContainer.getHost()}:${postgresContainer.getMappedPort(5432)}/crab_test`;
  process.env.MONGODB_URI = `mongodb://crab:crab@${mongoContainer.getHost()}:${mongoContainer.getMappedPort(27017)}/crab_test?authSource=admin`;
  process.env.REDIS_URL = `redis://${redisContainer.getHost()}:${redisContainer.getMappedPort(6379)}`;

  (global as any).__POSTGRES_CONTAINER__ = postgresContainer;
  (global as any).__MONGO_CONTAINER__ = mongoContainer;
  (global as any).__REDIS_CONTAINER__ = redisContainer;

  console.log('Test containers ready');
}
