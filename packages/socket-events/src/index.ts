import type { GeoLocation, RideStatus, OrderStatus, UserProfile } from '@crab/common-types';

// ============================================================
// Ride Namespace Events
// ============================================================
export interface RideRequestPayload {
  riderId: string;
  pickup: GeoLocation;
  dropoff: GeoLocation;
  paymentMethod: string;
}

export interface RideMatchedPayload {
  rideId: string;
  driver: Pick<UserProfile, 'id' | 'firstName' | 'lastName' | 'avatarUrl'>;
  estimatedArrival: number; // seconds
}

export interface RideAcceptedPayload {
  rideId: string;
  driverId: string;
  estimatedArrival: number;
}

export interface RideLocationPayload {
  rideId: string;
  location: GeoLocation;
  heading?: number;
  speed?: number;
}

export interface RideStatusPayload {
  rideId: string;
  status: RideStatus;
  timestamp: string;
}

export interface RideCompletedPayload {
  rideId: string;
  fare: number;
  duration: number; // seconds
  distance: number; // meters
}

export interface RideCancelPayload {
  rideId: string;
  reason?: string;
}

export interface RideCancelledPayload {
  rideId: string;
  cancelledBy: string;
  reason?: string;
}

export type RideNewRequestPayload = RideRequestPayload;

export interface RideRequestReceivedPayload {
  status: 'searching';
}

export interface RideJoinPayload {
  rideId: string;
}

export interface RideJoinedPayload {
  rideId: string;
}

export interface RideNamespaceEvents {
  'ride:request': RideRequestPayload;
  'ride:new_request': RideNewRequestPayload;
  'ride:request_received': RideRequestReceivedPayload;
  'ride:join': RideJoinPayload;
  'ride:joined': RideJoinedPayload;
  'ride:cancel': RideCancelPayload;
  'ride:matched': RideMatchedPayload;
  'ride:accepted': RideAcceptedPayload;
  'ride:location': RideLocationPayload;
  'ride:status': RideStatusPayload;
  'ride:completed': RideCompletedPayload;
  'ride:cancelled': RideCancelledPayload;
}

// ============================================================
// Food Namespace Events
// ============================================================
export interface OrderPlacedPayload {
  orderId: string;
  customerId: string;
  merchantId: string;
  items: Array<{ itemId: string; name: string; quantity: number; price: number }>;
  totalAmount: number;
}

export interface OrderStatusPayload {
  orderId: string;
  status: OrderStatus;
  timestamp: string;
  message?: string;
}

export interface OrderTrackingPayload {
  orderId: string;
  driverLocation: GeoLocation;
  estimatedDelivery: number; // seconds
}

export interface OrderReadyPayload {
  orderId: string;
  merchantId: string;
  readyAt: string;
}

export interface FoodNamespaceEvents {
  'order:placed': OrderPlacedPayload;
  'order:status': OrderStatusPayload;
  'order:tracking': OrderTrackingPayload;
  'order:ready': OrderReadyPayload;
}

// ============================================================
// Chat Namespace Events
// ============================================================
export interface ChatMessagePayload {
  messageId: string;
  roomId: string;
  senderId: string;
  content: string;
  contentType: 'text' | 'image' | 'location';
  timestamp: string;
}

export interface ChatTypingPayload {
  roomId: string;
  userId: string;
  isTyping: boolean;
}

export interface ChatReadPayload {
  roomId: string;
  userId: string;
  lastReadMessageId: string;
  readAt: string;
}

export interface ChatNamespaceEvents {
  'chat:message': ChatMessagePayload;
  'chat:typing': ChatTypingPayload;
  'chat:read': ChatReadPayload;
}

// ============================================================
// Notification Namespace Events
// ============================================================
export interface NotificationPayload {
  notificationId: string;
  userId: string;
  title: string;
  body: string;
  type: 'ride' | 'order' | 'chat' | 'system' | 'promo';
  data?: Record<string, unknown>;
  createdAt: string;
}

export interface NotificationReadPayload {
  notificationId: string;
  userId: string;
  readAt: string;
}

export interface NotificationNamespaceEvents {
  'notification:new': NotificationPayload;
  'notification:read': NotificationReadPayload;
}

// ============================================================
// Combined socket event map
// ============================================================
export type AllSocketEvents = RideNamespaceEvents &
  FoodNamespaceEvents &
  ChatNamespaceEvents &
  NotificationNamespaceEvents;
