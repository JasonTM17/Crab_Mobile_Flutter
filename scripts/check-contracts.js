const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')

const files = {
  openapi: read('docs/openapi.yaml'),
  commonTypes: read('packages/common-types/src/index.ts'),
  schema: read('scripts/schema.sql'),
  apiDocs: read('docs/API.md'),
  architectureDocs: read('docs/ARCHITECTURE.md'),
  testingDocs: read('docs/TESTING.md'),
  realtimeDocs: read('docs/REALTIME.md'),
  websocketDocs: read('docs/WEBSOCKET_EVENTS.md'),
  rideDocs: read('docs/RIDE_MATCHING.md'),
  commonTypesReadme: read('packages/common-types/README.md'),
  socketEvents: read('packages/socket-events/src/index.ts'),
  socketEventsReadme: read('packages/socket-events/README.md'),
  mobileOrderModel: read('apps/mobile/lib/features/food/data/models/order_model.dart'),
  webAdminRides: read('apps/web-admin/src/pages/Rides.tsx'),
  webAdminOrders: read('apps/web-admin/src/pages/Orders.tsx'),
}

const rideStatuses = ['REQUESTED', 'MATCHED', 'PICKUP', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED']
const orderStatuses = ['PLACED', 'CONFIRMED', 'PREPARING', 'READY', 'PICKED_UP', 'DELIVERED', 'CANCELLED']
let failures = 0

expectSequence('OpenAPI RideStatus enum', files.openapi, 'enum: [' + rideStatuses.join(', ') + ']')
expectSequence('OpenAPI OrderStatus enum', files.openapi, 'enum: [' + orderStatuses.join(', ') + ']')
expectSequence('common-types RideStatus enum', files.commonTypes, rideStatuses.map((s) => `${s} = '${s}'`).join(','))
expectSequence('common-types OrderStatus enum', files.commonTypes, orderStatuses.map((s) => `${s} = '${s}'`).join(','))
expectSequence('scripts/schema.sql ride default', files.schema, "status            VARCHAR(20) NOT NULL DEFAULT 'REQUESTED'")
expectSequence('scripts/schema.sql order default', files.schema, "status            VARCHAR(20) NOT NULL DEFAULT 'PLACED'")
expectSequence('OpenAPI local server base path', files.openapi, 'http://localhost:3000/api/v1')
expectSequence('OpenAPI production server base path', files.openapi, 'https://api.crab.app/api/v1')
expectSequence('OpenAPI profile route group', files.openapi, '/profiles/{userId}:')
expectSequence('OpenAPI restaurant search route', files.openapi, '/restaurants/search:')
expectSequence('OpenAPI wallet route group', files.openapi, '/wallet/{userId}:')
expectSequence('OpenAPI nested auth tokens', files.openapi, 'tokens:\n                    $ref:')
expectSequence('OpenAPI refresh request field', files.openapi, 'refresh_token:\n                  type: string')
expectSequence('OpenAPI ride flat create fields', files.openapi, 'required: [rider_id, pickup_lat, pickup_lng, pickup_address, dropoff_lat, dropoff_lng, dropoff_address]')
expectSequence('OpenAPI restaurant latitude query', files.openapi, 'name: latitude')
expectSequence('REST docs profile route group', files.apiDocs, '### GET /profiles/:userId')
expectSequence('REST docs restaurant search route', files.apiDocs, '### GET /restaurants/search')
expectSequence('REST docs wallet route group', files.apiDocs, '### GET /wallet/:userId')
expectSequence('REST docs nested auth tokens', files.apiDocs, '"tokens": {\n    "access_token"')
expectSequence('REST docs ride flat create fields', files.apiDocs, '"pickup_lat": 10.7769')
expectSequence('socket-events gateway ride new request', files.socketEvents, "'ride:new_request': RideNewRequestPayload")
expectSequence('socket-events gateway ride request ack', files.socketEvents, "'ride:request_received': RideRequestReceivedPayload")
expectSequence('socket-events gateway ride join ack', files.socketEvents, "'ride:joined': RideJoinedPayload")
expectSequence('socket-events gateway ride cancel', files.socketEvents, "'ride:cancel': RideCancelPayload")
expectSequence('socket-events README gateway ride new request', files.socketEventsReadme, '`ride:new_request`')

reject('OpenAPI status schemas', files.openapi, /\b(SEARCHING|ARRIVING|IN_TRIP|READY_FOR_PICKUP|OUT_FOR_DELIVERY|ACCEPTED|NO_DRIVERS_AVAILABLE)\b/)
reject('common-types enums', files.commonTypes, /\b(SEARCHING|ARRIVING|IN_TRIP|READY_FOR_PICKUP|OUT_FOR_DELIVERY|ACCEPTED|NO_DRIVERS_AVAILABLE)\b/)
reject('SQL bootstrap status defaults', files.schema, /\b(SEARCHING|ARRIVING|IN_TRIP|READY_FOR_PICKUP|OUT_FOR_DELIVERY|ACCEPTED|NO_DRIVERS_AVAILABLE)\b/)
reject('REST API docs', files.apiDocs, /\b(SEARCHING|ARRIVING|IN_TRIP|READY_FOR_PICKUP|OUT_FOR_DELIVERY|ACCEPTED|NO_DRIVERS_AVAILABLE)\b/)
reject('REST API route groups', files.apiDocs, /\/(users\/me|food\/restaurants|food\/orders|payments\/(wallet|topup|transactions))\b/)
reject('REST API token fields', files.apiDocs, /\b(accessToken|refreshToken)\b/)
reject('REST API ride create fields', files.apiDocs, /\b(pickupLocation|dropoffLocation|vehicleType)\b/)
reject('REST API payment top-up field', files.apiDocs, /"method"\s*:/)
reject('OpenAPI route groups', files.openapi, /\/(users\/me|food\/restaurants|food\/orders|payments\/(wallet|topup|transactions))\b/)
reject('OpenAPI token fields', files.openapi, /^\s+(accessToken|refreshToken):/m)
reject('OpenAPI ride create fields', files.openapi, /\b(pickupLocation|dropoffLocation|vehicleType)\b/)
reject('architecture route groups', files.architectureDocs, /\/(users\/me|food\/restaurants|food\/orders|payments\/(wallet|topup|transactions))\b/)
reject('testing route groups', files.testingDocs, /\/(users\/me|food\/restaurants|food\/orders|payments\/(wallet|topup|transactions))\b/)
reject('testing token fields', files.testingDocs, /\b(accessToken|refreshToken)\b/)
reject('testing ride create fields', files.testingDocs, /\b(pickupLocation|dropoffLocation|vehicleType)\b/)
reject('websocket docs ride create fields', files.websocketDocs, /\b(pickupLocation|dropoffLocation|vehicleType)\b/)
reject('real-time status docs', files.realtimeDocs, /ride:status\s+(SEARCHING|ARRIVING|IN_TRIP|READY_FOR_PICKUP|OUT_FOR_DELIVERY|ACCEPTED|NO_DRIVERS_AVAILABLE)\b/)
reject('ride lifecycle docs', files.rideDocs, /\b(SEARCHING|ARRIVING|IN_TRIP|READY_FOR_PICKUP|OUT_FOR_DELIVERY|ACCEPTED|NO_DRIVERS_AVAILABLE)\b/)
reject('common-types README', files.commonTypesReadme, /\b(SEARCHING|ARRIVING|IN_TRIP|READY_FOR_PICKUP|OUT_FOR_DELIVERY|ACCEPTED|NO_DRIVERS_AVAILABLE|PENDING|REJECTED)\b/)
reject('web-admin ride badges', files.webAdminRides, /\b(ACCEPTED|PENDING|CANCELED|FAILED)\b/)
reject('web-admin order badges', files.webAdminOrders, /\b(OUT_FOR_DELIVERY|PENDING|CANCELED|REFUNDED|COMPLETED)\b/)
reject('mobile food wire parser', files.mobileOrderModel, /\b(PENDING|READY_FOR_PICKUP|OUT_FOR_DELIVERY)\b/)

if (failures > 0) {
  process.exit(1)
}

console.log('Contract guardrails passed')

function read(relativePath) {
  const fullPath = path.join(root, relativePath)
  if (!fs.existsSync(fullPath)) {
    console.error(`Missing required contract file: ${relativePath}`)
    failures += 1
    return ''
  }

  return fs.readFileSync(fullPath, 'utf8')
}

function expectSequence(label, content, expected) {
  const normalizedContent = compact(content)
  const normalizedExpected = compact(expected)
  if (!normalizedContent.includes(normalizedExpected)) {
    console.error(`${label} is missing expected contract text: ${expected}`)
    failures += 1
  }
}

function reject(label, content, pattern) {
  if (pattern.test(content)) {
    console.error(`${label} contains non-canonical contract vocabulary: ${pattern}`)
    failures += 1
  }
}

function compact(value) {
  return value.replace(/\s+/g, '')
}
