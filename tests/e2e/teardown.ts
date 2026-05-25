import { StartedTestContainer } from 'testcontainers';

export default async function teardown() {
  console.log('\nStopping test containers...');

  const containers: StartedTestContainer[] = [
    (global as any).__POSTGRES_CONTAINER__,
    (global as any).__MONGO_CONTAINER__,
    (global as any).__REDIS_CONTAINER__,
  ].filter(Boolean);

  await Promise.all(containers.map((container) => container.stop()));

  console.log('Test containers stopped');
}
