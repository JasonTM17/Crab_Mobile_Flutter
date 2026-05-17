import { Location } from '@crab/common-types';

export const RIDE_EVENTS = {
  REQUEST: 'ride:request',
  ACCEPT: 'ride:accept',
  CANCEL: 'ride:cancel',
  ARRIVED: 'ride:arrived',
  START: 'ride:start',
  COMPLETE: 'ride:complete',
  REJOIN: 'ride:rejoin',
  NEW_REQUEST: 'ride:new_request',
  ACCEPTED: 'ride:accepted',
  DRIVER_LOCATION: 'ride:driver_location',
  STATUS_CHANGED: 'ride:status_changed',
  NO_DRIVER: 'ride:no_driver',
} as const;

export const FOOD_EVENTS = {
  ORDER_TRACK: 'order:track',
  ORDER_UNTRACK: 'order:untrack',
  ORDER_STATUS_CHANGED: 'order:status_changed',
  ORDER_DRIVER_ASSIGNED: 'order:driver_assigned',
  ORDER_DRIVER_LOCATION: 'order:driver_location',
} as const;

export const CHAT_EVENTS = {
  MESSAGE_SEND: 'message:send',
  MESSAGE_TYPING: 'message:typing',
  MESSAGE_READ: 'message:read',
  MESSAGE_NEW: 'message:new',
  MESSAGE_READ_RECEIPT: 'message:read_receipt',
} as const;

export const NOTIFICATION_EVENTS = {
  NEW: 'notification:new',
  BADGE_UPDATE: 'notification:badge_update',
} as const;

export const DRIVER_EVENTS = {
  LOCATION: 'driver:location',
} as const;

export interface RideRequestPayload {
  pickupLocation: Location;
  dropoffLocation: Location;
  vehicleType: 'bike' | 'car' | 'car_plus';
}

export interface RideAcceptPayload {
  rideId: string;
}

export interface RideCancelPayload {
  rideId: string;
  reason?: string;
}

export interface DriverLocationPayload {
  lat: number;
  lng: number;
  heading: number;
  speed: number;
}

export interface RideNewRequestPayload {
  rideId: string;
  pickupLocation: Location;
  dropoffLocation: Location;
  vehicleType: string;
  estimatedFare: number;
}

export interface RideAcceptedPayload {
  rideId: string;
  driver: {
    id: string;
    name: string;
    avatar: string;
    phone: string;
    vehiclePlate: string;
    vehicleModel: string;
    rating: number;
  };
  eta: number;
}

export interface RideDriverLocationPayload {
  rideId: string;
  lat: number;
  lng: number;
  heading: number;
  speed: number;
  eta: number;
}

export interface RideStatusChangedPayload {
  rideId: string;
  status: string;
  timestamp: string;
}

export interface MessageSendPayload {
  conversationId: string;
  text: string;
  type: 'text' | 'image' | 'location';
  imageUrl?: string;
  location?: Location;
}

export interface MessageNewPayload {
  id: string;
  conversationId: string;
  senderId: string;
  text: string;
  type: string;
  createdAt: string;
}

export interface MessageTypingPayload {
  conversationId: string;
  isTyping: boolean;
}

export interface NotificationPayload {
  id: string;
  type: string;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  createdAt: string;
}

export interface OrderStatusPayload {
  orderId: string;
  status: string;
  timestamp: string;
  estimatedTime?: number;
}
