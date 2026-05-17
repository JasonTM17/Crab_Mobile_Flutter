// ============================================================
// User Roles
// ============================================================
export enum UserRole {
  RIDER = 'RIDER',
  DRIVER = 'DRIVER',
  MERCHANT = 'MERCHANT',
  ADMIN = 'ADMIN',
}

// ============================================================
// Ride Status
// ============================================================
export enum RideStatus {
  REQUESTED = 'REQUESTED',
  MATCHED = 'MATCHED',
  PICKUP = 'PICKUP',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  CANCELLED = 'CANCELLED',
}

// ============================================================
// Order Status
// ============================================================
export enum OrderStatus {
  PLACED = 'PLACED',
  CONFIRMED = 'CONFIRMED',
  PREPARING = 'PREPARING',
  READY = 'READY',
  PICKED_UP = 'PICKED_UP',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
}

// ============================================================
// Payment Method
// ============================================================
export enum PaymentMethod {
  WALLET = 'WALLET',
  COD = 'COD',
  BANK_TRANSFER = 'BANK_TRANSFER',
}

// ============================================================
// User Status
// ============================================================
export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
  PENDING_VERIFICATION = 'PENDING_VERIFICATION',
}

// ============================================================
// Common DTOs
// ============================================================
export interface GeoLocation {
  latitude: number;
  longitude: number;
  address?: string;
}

export interface PaginationDto {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'ASC' | 'DESC';
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
  statusCode: number;
}

// ============================================================
// User interfaces
// ============================================================
export interface UserProfile {
  id: string;
  email: string;
  phone: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  status: UserStatus;
  avatarUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface JwtPayload {
  sub: string;
  email: string;
  role: UserRole;
  iat?: number;
  exp?: number;
}
