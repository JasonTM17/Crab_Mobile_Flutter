import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { v4 as uuid } from 'uuid';

const dataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL || 'postgresql://crab:crab@localhost:5432/crab',
  synchronize: false,
});

const SALT_ROUNDS = 12;

async function seed() {
  console.log('🌱 Seeding database...');
  await dataSource.initialize();
  const queryRunner = dataSource.createQueryRunner();

  try {
    await queryRunner.startTransaction();

    // Seed users
    const adminPassword = await bcrypt.hash('Admin123!', SALT_ROUNDS);
    const userPassword = await bcrypt.hash('User123!', SALT_ROUNDS);
    const driverPassword = await bcrypt.hash('Driver123!', SALT_ROUNDS);

    const adminId = uuid();
    const riderId = uuid();
    const driverId = uuid();
    const restaurantOwnerId = uuid();

    await queryRunner.query(`
      INSERT INTO users (id, email, password_hash, full_name, phone, role, is_active, is_verified)
      VALUES
        ($1, 'admin@crab.app', $5, 'Admin User', '+84900000001', 'admin', true, true),
        ($2, 'rider@crab.app', $6, 'Nguyen Van Rider', '+84900000002', 'rider', true, true),
        ($3, 'driver@crab.app', $7, 'Tran Van Driver', '+84900000003', 'driver', true, true),
        ($4, 'restaurant@crab.app', $6, 'Le Thi Restaurant', '+84900000004', 'restaurant_owner', true, true)
      ON CONFLICT (email) DO NOTHING
    `, [adminId, riderId, driverId, restaurantOwnerId, adminPassword, userPassword, driverPassword]);

    console.log('✅ Users seeded');

    // Seed wallets
    await queryRunner.query(`
      INSERT INTO wallets (id, user_id, balance, currency)
      VALUES
        ($1, $5, 500000, 'VND'),
        ($2, $6, 1000000, 'VND'),
        ($3, $7, 2500000, 'VND'),
        ($4, $8, 0, 'VND')
      ON CONFLICT (user_id) DO NOTHING
    `, [uuid(), uuid(), uuid(), uuid(), adminId, riderId, driverId, restaurantOwnerId]);

    console.log('✅ Wallets seeded');

    // Seed driver profile
    await queryRunner.query(`
      INSERT INTO driver_profiles (id, user_id, license_number, vehicle_type, vehicle_plate, vehicle_model, is_online, current_lat, current_lng, rating_avg)
      VALUES ($1, $2, 'B2-123456', 'car', '59A-12345', 'Toyota Vios 2023', true, 10.7769, 106.7009, 4.85)
      ON CONFLICT (user_id) DO NOTHING
    `, [uuid(), driverId]);

    console.log('✅ Driver profile seeded');

    // Seed restaurants
    const restaurantId = uuid();
    await queryRunner.query(`
      INSERT INTO restaurants (id, owner_id, name, description, category, address, lat, lng, phone, is_open, delivery_fee, min_order, rating_avg)
      VALUES
        ($1, $2, 'Pho Saigon 24h', 'Authentic Vietnamese pho, open 24 hours', 'vietnamese', '24 Tran Hung Dao, District 1, HCMC', 10.7725, 106.6980, '+84281234567', true, 15000, 30000, 4.7),
        ($3, $2, 'Banh Mi Express', 'Fresh banh mi sandwiches made to order', 'street_food', '88 Le Loi, District 1, HCMC', 10.7731, 106.7000, '+84281234568', true, 10000, 20000, 4.5),
        ($4, $2, 'Cafe Rooftop', 'Premium Vietnamese coffee with city views', 'cafe', '100 Nguyen Hue, District 1, HCMC', 10.7740, 106.7020, '+84281234569', true, 20000, 25000, 4.8)
      ON CONFLICT DO NOTHING
    `, [restaurantId, restaurantOwnerId, uuid(), uuid()]);

    console.log('✅ Restaurants seeded');

    // Seed menu items
    await queryRunner.query(`
      INSERT INTO menu_items (id, restaurant_id, category_name, name, description, price, is_available, sort_order)
      VALUES
        ($1, $8, 'Pho', 'Pho Bo Tai', 'Rare beef pho with fresh herbs', 55000, true, 1),
        ($2, $8, 'Pho', 'Pho Bo Chin', 'Well-done beef brisket pho', 55000, true, 2),
        ($3, $8, 'Pho', 'Pho Ga', 'Chicken pho with shredded meat', 50000, true, 3),
        ($4, $8, 'Sides', 'Gio Chao Quay', 'Fried dough sticks (2 pcs)', 15000, true, 4),
        ($5, $8, 'Sides', 'Trung Lon', 'Balut egg', 12000, true, 5),
        ($6, $8, 'Drinks', 'Tra Da', 'Vietnamese iced tea', 5000, true, 6),
        ($7, $8, 'Drinks', 'Ca Phe Sua Da', 'Vietnamese iced coffee with milk', 25000, true, 7)
      ON CONFLICT DO NOTHING
    `, [uuid(), uuid(), uuid(), uuid(), uuid(), uuid(), uuid(), restaurantId]);

    console.log('✅ Menu items seeded');

    await queryRunner.commitTransaction();
    console.log('\n🎉 Database seeded successfully!');
    console.log('\n📋 Demo Accounts:');
    console.log('  Admin:      admin@crab.app / Admin123!');
    console.log('  Rider:      rider@crab.app / User123!');
    console.log('  Driver:     driver@crab.app / Driver123!');
    console.log('  Restaurant: restaurant@crab.app / User123!');
  } catch (error) {
    await queryRunner.rollbackTransaction();
    console.error('❌ Seed failed:', error.message);
    process.exit(1);
  } finally {
    await queryRunner.release();
    await dataSource.destroy();
  }
}

seed();
