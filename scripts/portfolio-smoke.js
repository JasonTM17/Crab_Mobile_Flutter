const DEFAULT_GATEWAY_BASE = 'http://localhost:3000'

const gatewayBase = trimTrailingSlash(
  process.env.CRAB_GATEWAY_BASE || DEFAULT_GATEWAY_BASE,
)
const apiBase = trimTrailingSlash(
  process.env.CRAB_API_BASE || `${gatewayBase}/api/v1`,
)

const demo = {
  admin: {
    email: process.env.CRAB_ADMIN_EMAIL || 'admin@crab.app',
    password: process.env.CRAB_ADMIN_PASSWORD || 'Admin123!',
    role: 'ADMIN',
  },
  rider: {
    email: process.env.CRAB_RIDER_EMAIL || 'rider@crab.app',
    password: process.env.CRAB_RIDER_PASSWORD || 'User123!',
    role: 'RIDER',
  },
  driver: {
    email: process.env.CRAB_DRIVER_EMAIL || 'driver@crab.app',
    password: process.env.CRAB_DRIVER_PASSWORD || 'Driver123!',
    role: 'DRIVER',
  },
  merchant: {
    email: process.env.CRAB_MERCHANT_EMAIL || 'merchant@crab.app',
    password: process.env.CRAB_MERCHANT_PASSWORD || 'User123!',
    role: 'MERCHANT',
  },
}

main().catch((error) => {
  console.error(error.message)
  process.exit(1)
})

async function main() {
  const runId = `e2e-${Date.now()}-${process.pid}`
  const ctx = { runId }

  await group('gateway', async () => {
    await request('gateway health', `${gatewayBase}/health`, {}, (body) => body.status === 'ok')
    await request(
      'proxy health',
      `${apiBase}/proxy/health`,
      {},
      (body) => body.gateway === 'ok' && typeof body.circuits === 'object',
    )
  })

  await group('auth and roles', async () => {
    ctx.admin = await login('admin login', demo.admin)
    ctx.rider = await login('rider login', demo.rider)
    ctx.driver = await login('driver login', demo.driver)
    ctx.merchant = await login('merchant login', demo.merchant)

    await expectStatus(
      'protected route rejects anonymous request',
      `${apiBase}/profiles/${ctx.rider.user.id}`,
      401,
    )
    await request(
      'auth me',
      `${apiBase}/auth/me`,
      { headers: auth(ctx.rider) },
      (body) => body.user?.id === ctx.rider.user.id || body.id === ctx.rider.user.id,
    )
  })

  await group('profile and addresses', async () => {
    await request(
      'rider profile',
      `${apiBase}/profiles/${ctx.rider.user.id}`,
      { headers: auth(ctx.rider) },
      (body) => body.userId === ctx.rider.user.id || body.id === ctx.rider.user.id,
    )
    await request(
      'rider addresses',
      `${apiBase}/addresses/${ctx.rider.user.id}`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body) && body.length > 0,
    )
  })

  await group('payment wallet', async () => {
    const before = await request(
      'wallet balance before top-up',
      `${apiBase}/wallet/${ctx.rider.user.id}`,
      { headers: auth(ctx.rider) },
      (body) => isNumeric(body.balance),
    )
    const topUpAmount = 10000
    const topUp = await request(
      'wallet top-up',
      `${apiBase}/wallet/${ctx.rider.user.id}/top-up`,
      {
        method: 'POST',
        headers: auth(ctx.rider),
        body: {
          amount: topUpAmount,
          paymentMethod: 'E2E_DEMO',
          reference: `${runId}-top-up`,
        },
      },
      (body) => Boolean(body.id && body.status === 'COMPLETED'),
    )
    await request(
      'wallet balance after top-up',
      `${apiBase}/wallet/${ctx.rider.user.id}`,
      { headers: auth(ctx.rider) },
      (body) => Number(body.balance) >= Number(before.balance) + topUpAmount,
    )
    await request(
      'transaction history includes top-up',
      `${apiBase}/transactions/user/${ctx.rider.user.id}?limit=20`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body.data) && body.data.some((tx) => tx.id === topUp.id),
    )
  })

  await group('food order lifecycle', async () => {
    const restaurants = await request(
      'restaurant discovery',
      `${apiBase}/restaurants/search`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body.data) && body.data.length > 0,
    )
    ctx.restaurant = restaurants.data[0]

    const menuItems = await request(
      'menu item lookup',
      `${apiBase}/menus/items/restaurant/${ctx.restaurant.id}`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body) && body.length > 0,
    )
    const menuItem = menuItems[0]

    const order = await request(
      'order creation',
      `${apiBase}/orders`,
      {
        method: 'POST',
        headers: auth(ctx.rider),
        body: {
          customerId: ctx.rider.user.id,
          restaurantId: ctx.restaurant.id,
          items: [{ menuItemId: menuItem.id, quantity: 1 }],
          deliveryLat: 10.7769,
          deliveryLng: 106.7009,
          deliveryAddress: `Crab E2E Delivery ${runId}`,
          deliveryNotes: 'Created by portfolio E2E',
          paymentMethod: 'WALLET',
        },
      },
      (body) => Boolean(body.id && body.status === 'PLACED'),
    )
    ctx.order = order

    await request(
      'customer active order',
      `${apiBase}/orders/customer/${ctx.rider.user.id}/active`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body) && body.some((item) => item.id === order.id),
    )
    await request(
      'restaurant order view',
      `${apiBase}/orders/restaurant/${ctx.restaurant.id}`,
      { headers: auth(ctx.merchant) },
      (body) => Array.isArray(body) && body.some((item) => item.id === order.id),
    )

    for (const status of ['CONFIRMED', 'PREPARING', 'READY']) {
      await updateOrderStatus(ctx, order.id, status)
    }
    await request(
      'assign order driver',
      `${apiBase}/orders/${order.id}/assign-driver`,
      {
        method: 'PUT',
        headers: auth(ctx.merchant),
        body: { driverId: ctx.driver.user.id },
      },
      (body) => body.id === order.id && body.driverId === ctx.driver.user.id,
    )
    await updateOrderStatus(ctx, order.id, 'PICKED_UP', { driverId: ctx.driver.user.id })
    await updateOrderStatus(ctx, order.id, 'DELIVERED')
    await request(
      'order delivered lookup',
      `${apiBase}/orders/${order.id}`,
      { headers: auth(ctx.rider) },
      (body) => body.id === order.id && body.status === 'DELIVERED' && body.paid === true,
    )
    await request(
      'restaurant order stats',
      `${apiBase}/orders/stats/restaurant/${ctx.restaurant.id}?days=30`,
      { headers: auth(ctx.merchant) },
      (body) => body.restaurantId === ctx.restaurant.id && Number(body.totalOrders) >= 1,
    )
  })

  await group('ride lifecycle', async () => {
    await request(
      'fare estimate',
      `${apiBase}/rides/estimate`,
      {
        method: 'POST',
        headers: auth(ctx.rider),
        body: {
          pickup_lat: 10.7769,
          pickup_lng: 106.7009,
          dropoff_lat: 10.8015,
          dropoff_lng: 106.7147,
          vehicle_type: 'BIKE',
        },
      },
      (body) => body.vehicleType === 'BIKE' && Number(body.total_fare) > 0,
    )

    const ride = await request(
      'ride creation',
      `${apiBase}/rides`,
      {
        method: 'POST',
        headers: auth(ctx.rider),
        body: {
          rider_id: ctx.rider.user.id,
          pickup_lat: 10.7769,
          pickup_lng: 106.7009,
          pickup_address: `Crab E2E Pickup ${runId}`,
          dropoff_lat: 10.8015,
          dropoff_lng: 106.7147,
          dropoff_address: `Crab E2E Dropoff ${runId}`,
          vehicle_type: 'BIKE',
        },
      },
      (body) => Boolean(body.data?.id && body.data.status === 'REQUESTED'),
    )
    ctx.ride = ride.data

    await request(
      'driver accepts ride',
      `${apiBase}/rides/${ctx.ride.id}/accept`,
      {
        method: 'POST',
        headers: auth(ctx.driver),
        body: { driverId: ctx.driver.user.id },
      },
      (body) => body.data?.id === ctx.ride.id && body.data.status === 'MATCHED',
    )
    await request(
      'active ride for rider',
      `${apiBase}/rides/active/rider/${ctx.rider.user.id}`,
      { headers: auth(ctx.rider) },
      (body) => body?.id === ctx.ride.id,
    )
    await request(
      'active ride for driver',
      `${apiBase}/rides/active/driver/${ctx.driver.user.id}`,
      { headers: auth(ctx.driver) },
      (body) => body?.id === ctx.ride.id,
    )

    for (const status of ['PICKUP', 'IN_PROGRESS', 'COMPLETED']) {
      await request(
        `ride status ${status}`,
        `${apiBase}/rides/${ctx.ride.id}/status`,
        {
          method: 'PATCH',
          headers: auth(ctx.driver),
          body: { status, driver_id: ctx.driver.user.id },
        },
        (body) => body.data?.id === ctx.ride.id && body.data.status === status,
      )
    }
    await request(
      'rider ride history',
      `${apiBase}/rides/rider/${ctx.rider.user.id}`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body.data) && body.data.some((item) => item.id === ctx.ride.id),
    )
    await request(
      'driver ride stats',
      `${apiBase}/rides/stats/driver/${ctx.driver.user.id}?days=30`,
      { headers: auth(ctx.driver) },
      (body) => body.driverId === ctx.driver.user.id && Number(body.totalRides) >= 1,
    )
  })

  await group('ratings', async () => {
    const orderRating = await request(
      'restaurant rating create',
      `${apiBase}/ratings`,
      {
        method: 'POST',
        headers: auth(ctx.rider),
        body: {
          raterId: ctx.rider.user.id,
          targetId: ctx.restaurant.id,
          targetType: 'RESTAURANT',
          context: 'ORDER',
          referenceId: ctx.order.id,
          score: 5,
          review: 'Portfolio E2E restaurant rating',
          tags: ['e2e', 'portfolio'],
        },
      },
      (body) => Boolean(body.id && body.referenceId === ctx.order.id),
    )
    await request(
      'rating reference lookup',
      `${apiBase}/ratings/reference/${ctx.order.id}`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body) && body.some((item) => item.id === orderRating.id),
    )
    await request(
      'restaurant rating aggregate',
      `${apiBase}/ratings/aggregate/RESTAURANT/${ctx.restaurant.id}`,
      { headers: auth(ctx.rider) },
      (body) => body.targetId === ctx.restaurant.id && Number(body.totalRatings) >= 1,
    )
    await request(
      'ratings by rater',
      `${apiBase}/ratings/rater/${ctx.rider.user.id}?limit=20`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body) && body.some((item) => item.id === orderRating.id),
    )
  })

  await group('notifications', async () => {
    await request(
      'send notification',
      `${apiBase}/notifications`,
      {
        method: 'POST',
        headers: auth(ctx.admin),
        body: {
          userId: ctx.rider.user.id,
          title: `Crab E2E ${runId}`,
          body: 'Portfolio E2E notification',
          type: 'system',
          channels: ['in_app'],
          data: { runId },
        },
      },
      (body) => Boolean(body._id || body.id),
    )
    const list = await request(
      'notification list',
      `${apiBase}/notifications/user/${ctx.rider.user.id}?limit=20`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body.data) && body.data.some((item) => item.data?.runId === runId),
    )
    const notification = list.data.find((item) => item.data?.runId === runId)
    const notificationId = documentId(notification)
    await request(
      'notification unread count',
      `${apiBase}/notifications/user/${ctx.rider.user.id}/unread-count`,
      { headers: auth(ctx.rider) },
      (body) => Number(body) >= 1,
    )
    await request(
      'mark notification read',
      `${apiBase}/notifications/${notificationId}/read`,
      { method: 'PUT', headers: auth(ctx.rider) },
      (body) => body?.read === true,
    )
    await request(
      'mark all notifications read',
      `${apiBase}/notifications/user/${ctx.rider.user.id}/read-all`,
      { method: 'PUT', headers: auth(ctx.rider) },
      (body) => Number(body.updated) >= 0,
    )
  })

  await group('chat', async () => {
    const room = await request(
      'chat room create',
      `${apiBase}/chats/rooms`,
      {
        method: 'POST',
        headers: auth(ctx.rider),
        body: {
          type: 'RIDE',
          participants: [ctx.rider.user.id, ctx.driver.user.id],
          referenceId: ctx.ride.id,
        },
      },
      (body) => Boolean(documentId(body)) && Array.isArray(body.participants),
    )
    const roomId = documentId(room)
    const message = await request(
      'chat message send',
      `${apiBase}/chats/messages`,
      {
        method: 'POST',
        headers: auth(ctx.rider),
        body: {
          roomId,
          senderId: ctx.rider.user.id,
          content: `Portfolio E2E message ${runId}`,
          type: 'text',
          metadata: { runId },
        },
      },
      (body) => Boolean(documentId(body)) && body.roomId === roomId,
    )
    await request(
      'chat message list',
      `${apiBase}/chats/messages/room/${roomId}?limit=20`,
      { headers: auth(ctx.rider) },
      (body) => Array.isArray(body.data) && body.data.some((item) => documentId(item) === documentId(message)),
    )
    await request(
      'mark chat room read',
      `${apiBase}/chats/rooms/${roomId}/read`,
      {
        method: 'PUT',
        headers: auth(ctx.driver),
        body: { userId: ctx.driver.user.id, lastMessageId: documentId(message) },
      },
      () => true,
    )
  })

  console.log('Portfolio E2E checks passed')
}

async function group(name, fn) {
  console.log(`\n[${name}]`)
  await fn()
}

async function login(label, account) {
  const session = await request(
    label,
    `${apiBase}/auth/login`,
    {
      method: 'POST',
      body: { email: account.email, password: account.password },
    },
    (body) => Boolean(body.user?.id && body.tokens?.access_token),
  )
  if (session.user.role !== account.role) {
    throw new Error(`${label} returned role=${session.user.role ?? 'unknown'}`)
  }
  return session
}

async function updateOrderStatus(ctx, orderId, status, extra = {}) {
  return request(
    `order status ${status}`,
    `${apiBase}/orders/${orderId}/status`,
    {
      method: 'PUT',
      headers: auth(ctx.merchant),
      body: { status, ...extra },
    },
    (body) => body.id === orderId && body.status === status,
  )
}

async function expectStatus(label, url, expectedStatus, options = {}) {
  const response = await rawRequest(label, url, options)
  if (response.status !== expectedStatus) {
    throw new Error(`${label} expected HTTP ${expectedStatus}, got ${response.status}: ${snippet(response.text)}`)
  }
  console.log(`${label}: ok`)
  return response.body
}

async function request(label, url, options = {}, validate) {
  const response = await rawRequest(label, url, options)
  if (!response.ok) {
    throw new Error(`${label} failed: HTTP ${response.status} ${snippet(response.text)}`)
  }
  if (validate && !validate(response.body)) {
    throw new Error(`${label} returned unexpected payload: ${snippet(response.text)}`)
  }

  console.log(`${label}: ok`)
  return response.body
}

async function rawRequest(label, url, options = {}) {
  const controller = new AbortController()
  const timeout = setTimeout(
    () => controller.abort(),
    Number(process.env.CRAB_SMOKE_TIMEOUT_MS || 10000),
  )
  const headers = {
    ...(options.body ? { 'Content-Type': 'application/json' } : {}),
    ...(options.headers || {}),
  }

  let response
  let text
  try {
    response = await fetch(url, {
      method: options.method || 'GET',
      headers,
      body: options.body ? JSON.stringify(options.body) : undefined,
      signal: controller.signal,
    })
    text = await response.text()
  } catch (error) {
    throw new Error(
      `${label} failed: ${error.message}. Ensure the local Docker stack is running and reachable at ${gatewayBase}.`,
    )
  } finally {
    clearTimeout(timeout)
  }

  return {
    ok: response.ok,
    status: response.status,
    text,
    body: parseJson(text),
  }
}

function auth(session) {
  return { Authorization: `Bearer ${session.tokens.access_token}` }
}

function documentId(document) {
  return document?.id || document?._id || document?.data?.id || document?.data?._id
}

function isNumeric(value) {
  return typeof value === 'number' || (typeof value === 'string' && value.trim().length > 0 && !Number.isNaN(Number(value)))
}

function parseJson(text) {
  if (!text) return {}
  try {
    return JSON.parse(text)
  } catch {
    return { raw: text }
  }
}

function snippet(text) {
  return (text || '').replace(/\s+/g, ' ').trim().slice(0, 300)
}

function trimTrailingSlash(value) {
  return value.replace(/\/+$/, '')
}
