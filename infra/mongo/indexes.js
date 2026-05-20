// MongoDB hot-path indexes for Crab Super App
// Run with:  mongosh "$MONGODB_URI" < infra/mongo/indexes.js
//
// Idempotent: createIndex with the same key/options is a no-op.
// Date: 2026-05-20

// ── ride-service: driver_locations ────────────────────────────────────
const rides = db.getSiblingDB('crab_rides')
rides.driver_locations.createIndex(
  { location: '2dsphere' },
  { name: 'idx_driver_locations_geo' },
)
rides.driver_locations.createIndex(
  { status: 1, vehicleType: 1 },
  { name: 'idx_driver_locations_status_vehicle' },
)
rides.driver_locations.createIndex(
  { driverId: 1 },
  { name: 'idx_driver_locations_driver', unique: true },
)
rides.driver_locations.createIndex(
  { updatedAt: 1 },
  { name: 'idx_driver_locations_updated', expireAfterSeconds: 86400 },
)

// ── chat-service: messages ────────────────────────────────────────────
const chat = db.getSiblingDB('crab_chat')
chat.messages.createIndex(
  { roomId: 1, createdAt: -1 },
  { name: 'idx_messages_room_created' },
)
chat.messages.createIndex(
  { senderId: 1, createdAt: -1 },
  { name: 'idx_messages_sender_created' },
)
chat.rooms.createIndex(
  { 'participants.userId': 1 },
  { name: 'idx_rooms_participant' },
)

// ── notification-service: notifications ────────────────────────────────
const notif = db.getSiblingDB('crab_notifications')
notif.notifications.createIndex(
  { userId: 1, createdAt: -1 },
  { name: 'idx_notifications_user_created' },
)
notif.notifications.createIndex(
  { userId: 1, isRead: 1, createdAt: -1 },
  { name: 'idx_notifications_user_read_created' },
)
notif.notifications.createIndex(
  { type: 1, createdAt: -1 },
  { name: 'idx_notifications_type_created' },
)

// ── rating-service: reviews ────────────────────────────────────────────
const rating = db.getSiblingDB('crab_ratings')
rating.reviews.createIndex(
  { targetType: 1, targetId: 1, createdAt: -1 },
  { name: 'idx_reviews_target' },
)
rating.reviews.createIndex(
  { userId: 1, createdAt: -1 },
  { name: 'idx_reviews_user_created' },
)

print('✓ MongoDB hot-path indexes ensured.')
