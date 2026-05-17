export enum UserRole {
  RIDER = 'rider',
  DRIVER = 'driver',
  RESTAURANT_OWNER = 'restaurant_owner',
  ADMIN = 'admin',
}

export enum RideStatus {
  SEARCHING = 'SEARCHING',
  ACCEPTED = 'ACCEPTED',
  ARRIVING = 'ARRIVING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
  NO_DRIVER = 'NO_DRIVER',
}

export enum FoodOrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  PREPARING = 'PREPARING',
  READY = 'READY',
  PICKED_UP = 'PICKED_UP',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
  REJECTED = 'REJECTED',
}

export enum VehicleType {
  BIKE = 'bike',
  CAR = 'car',
  CAR_PLUS = 'car_plus',
}

export enum TransactionType {
  TOPUP = 'topup',
  RIDE_PAYMENT = 'ride_payment',
  FOOD_PAYMENT = 'food_payment',
  REFUND = 'refund',
  WITHDRAWAL = 'withdrawal',
}

export enum NotificationType {
  RIDE_ACCEPTED = 'ride_accepted',
  RIDE_COMPLETED = 'ride_completed',
  ORDER_CONFIRMED = 'order_confirmed',
  ORDER_READY = 'order_ready',
  ORDER_DELIVERED = 'order_delivered',
  PAYMENT_RECEIVED = 'payment_received',
  PROMO = 'promo',
  SYSTEM = 'system',
}

export interface Location {
  lat: number;
  lng: number;
  address?: string;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: PaginationMeta;
}

export interface ApiError {
  statusCode: number;
  message: string;
  errors?: Array<{ field: string; message: string }>;
  timestamp: string;
}

export interface UserPayload {
  id: string;
  email: string;
  role: UserRole;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}
