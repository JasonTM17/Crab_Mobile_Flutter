import { UserRole } from '@crab/common-types';

export const testUsers = {
  rider: {
    id: '550e8400-e29b-41d4-a716-446655440001',
    email: 'rider@test.com',
    password: 'TestPass123!',
    fullName: 'Test Rider',
    phone: '+84901000001',
    role: UserRole.RIDER,
  },
  driver: {
    id: '550e8400-e29b-41d4-a716-446655440002',
    email: 'driver@test.com',
    password: 'TestPass123!',
    fullName: 'Test Driver',
    phone: '+84901000002',
    role: UserRole.DRIVER,
  },
  restaurantOwner: {
    id: '550e8400-e29b-41d4-a716-446655440003',
    email: 'restaurant@test.com',
    password: 'TestPass123!',
    fullName: 'Test Restaurant Owner',
    phone: '+84901000003',
    role: UserRole.RESTAURANT_OWNER,
  },
  admin: {
    id: '550e8400-e29b-41d4-a716-446655440004',
    email: 'admin@test.com',
    password: 'AdminPass123!',
    fullName: 'Test Admin',
    phone: '+84901000004',
    role: UserRole.ADMIN,
  },
};

export const testLocations = {
  district1: { lat: 10.7769, lng: 106.7009, address: '123 Nguyen Hue, District 1, HCMC' },
  district3: { lat: 10.7834, lng: 106.6868, address: '456 Vo Van Tan, District 3, HCMC' },
  district7: { lat: 10.7295, lng: 106.7218, address: '789 Nguyen Van Linh, District 7, HCMC' },
  airport: { lat: 10.8184, lng: 106.6588, address: 'Tan Son Nhat Airport, HCMC' },
};

export const testRestaurant = {
  id: '550e8400-e29b-41d4-a716-446655440010',
  name: 'Pho 24 Test',
  category: 'vietnamese',
  address: '24 Tran Hung Dao, District 1',
  lat: 10.7725,
  lng: 106.698,
  deliveryFee: 15000,
  minOrder: 30000,
};

export const testMenuItems = [
  {
    id: '550e8400-e29b-41d4-a716-446655440020',
    name: 'Pho Bo',
    description: 'Traditional beef noodle soup',
    price: 55000,
    categoryName: 'Main Dishes',
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440021',
    name: 'Bun Cha',
    description: 'Grilled pork with noodles',
    price: 60000,
    categoryName: 'Main Dishes',
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440022',
    name: 'Ca Phe Sua Da',
    description: 'Vietnamese iced coffee',
    price: 25000,
    categoryName: 'Drinks',
  },
];
