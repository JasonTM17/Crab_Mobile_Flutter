import { StartedTestContainer } from 'testcontainers';

export default async function teardown() {
  console.log('\n🧹 Stopping test containers...');

  const containers: StartedTestContainer[] = [
    (global as any).__POSTGRES_CONTAINER__,
    (global as any).__MONGO_CONTAINER__,
    (global as any).__REDIS_CONTAINER__,
  ].filter(Boolean);

  await Promise.all(containers.map((c) => c.stop()));

  console.log('✅ Test containers stopped');
}
