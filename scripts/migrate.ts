import { DataSource } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';

const dataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL || 'postgresql://crab:crab@localhost:5432/crab',
  synchronize: false,
});

const SCHEMA_FILE = path.join(__dirname, '..', 'scripts', 'schema.sql');

async function migrate() {
  console.log('🔄 Running database migrations...');
  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();

  try {
    const schema = fs.readFileSync(SCHEMA_FILE, 'utf-8');
    const statements = schema
      .split(';')
      .map((s) => s.trim())
      .filter((s) => s.length > 0);

    for (const statement of statements) {
      await queryRunner.query(statement);
    }

    console.log(`✅ Executed ${statements.length} statements`);
    console.log('🎉 Migration complete!');
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    process.exit(1);
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

migrate();
