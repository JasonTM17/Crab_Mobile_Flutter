const fs = require('node:fs')
const path = require('node:path')
const { spawn, spawnSync } = require('node:child_process')
const { chromium } = require('playwright')

const root = path.resolve(__dirname, '..')
const screenshotsDir = path.join(root, 'docs', 'screenshots')
const baseUrl =
  process.env.ADMIN_SCREENSHOT_BASE_URL ?? 'http://127.0.0.1:5178'
const chromeCandidates = [
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe',
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
]

const dashboardFixture = {
  totalUsers: 48216,
  activeRides: 318,
  ordersToday: 1264,
  revenueMonth: 1842500000,
  ridesByHour: [
    { hour: '00', count: 42 },
    { hour: '03', count: 28 },
    { hour: '06', count: 148 },
    { hour: '09', count: 312 },
    { hour: '12', count: 286 },
    { hour: '15', count: 241 },
    { hour: '18', count: 421 },
    { hour: '21', count: 216 },
  ],
  topRestaurants: [
    { name: 'Crab Kitchen', orders: 246 },
    { name: 'Saigon Bites', orders: 192 },
    { name: 'Pho 24/7', orders: 166 },
    { name: 'Bun Bo House', orders: 142 },
  ],
  vehicleMix: [
    { type: 'BIKE', value: 856 },
    { type: 'CAR_4', value: 247 },
    { type: 'CAR_7', value: 118 },
    { type: 'PREMIUM', value: 41 },
  ],
}

const demoUser = {
  id: 'admin-demo',
  email: 'admin@crab.app',
  firstName: 'Crab',
  lastName: 'Operations',
  name: 'Crab Operations',
  role: 'ADMIN',
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})

async function main() {
  fs.mkdirSync(screenshotsDir, { recursive: true })
  const server = await ensureServer()
  const executablePath = resolveBrowserExecutable()
  const browser = await chromium.launch({
    headless: true,
    ...(executablePath ? { executablePath } : {}),
  })

  try {
    await captureLogin(browser, { width: 1440, height: 1024 }, 'admin-01-login.png')
    await captureDashboard(
      browser,
      { width: 1440, height: 1080 },
      'admin-02-dashboard.png',
    )
    await captureDashboard(
      browser,
      { width: 390, height: 844, isMobile: true },
      'admin-mobile-01-dashboard.png',
    )
    await captureLogin(
      browser,
      { width: 390, height: 844, isMobile: true },
      'admin-mobile-02-login.png',
    )
  } finally {
    await browser.close()
    if (server) {
      terminateServer(server)
    }
  }

  console.log('Admin release screenshots updated')
}

async function captureLogin(browser, viewport, fileName) {
  const context = await newContext(browser, viewport)
  const page = await context.newPage()
  await page.goto(`${baseUrl}/login`, { waitUntil: 'networkidle' })
  await page.getByText('Admin Portal').waitFor({ timeout: 15_000 })
  await page.waitForTimeout(500)
  await page.screenshot({
    path: path.join(screenshotsDir, fileName),
    fullPage: false,
  })
  await context.close()
}

async function captureDashboard(browser, viewport, fileName) {
  const context = await newContext(browser, viewport)
  await context.addInitScript((user) => {
    window.localStorage.setItem('access_token', 'portfolio-demo-token')
    window.localStorage.setItem('refresh_token', 'portfolio-demo-refresh')
    window.localStorage.setItem('user', JSON.stringify(user))
  }, demoUser)

  const page = await context.newPage()
  await page.route('**/api/v1/admin/dashboard', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({ data: dashboardFixture }),
    })
  })

  await page.goto(`${baseUrl}/dashboard`, { waitUntil: 'networkidle' })
  await page.getByText('Vehicle type distribution').waitFor({
    timeout: 15_000,
  })
  await page.locator('svg.recharts-surface').first().waitFor({
    timeout: 15_000,
  })
  await page.waitForTimeout(1000)
  await page.screenshot({
    path: path.join(screenshotsDir, fileName),
    fullPage: true,
  })
  await context.close()
}

async function ensureServer() {
  if (await isReachable(baseUrl)) {
    return null
  }

  const port = new URL(baseUrl).port || '5173'
  const viteCommand = path.join(
    root,
    'apps',
    'web-admin',
    'node_modules',
    '.bin',
    process.platform === 'win32' ? 'vite.cmd' : 'vite',
  )
  const command = process.platform === 'win32' ? 'powershell.exe' : viteCommand
  const args =
    process.platform === 'win32'
      ? [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          `& '${viteCommand}' --host 127.0.0.1 --port ${port} --strictPort`,
        ]
      : ['--host', '127.0.0.1', '--port', port, '--strictPort']
  const debugServer = process.env.ADMIN_SCREENSHOT_DEBUG === 'true'
  const server = spawn(command, args, {
    cwd: path.join(root, 'apps', 'web-admin'),
    stdio: debugServer ? 'pipe' : 'ignore',
    windowsHide: true,
  })

  if (debugServer) {
    server.stdout.on('data', (chunk) => process.stdout.write(chunk))
    server.stderr.on('data', (chunk) => process.stderr.write(chunk))
  }

  for (let attempt = 0; attempt < 80; attempt += 1) {
    if (await isReachable(baseUrl)) return server
    await delay(250)
  }

  server.kill()
  throw new Error(`Timed out waiting for ${baseUrl}`)
}

async function isReachable(url) {
  try {
    const response = await fetch(url)
    return response.ok
  } catch {
    return false
  }
}

function resolveBrowserExecutable() {
  if (process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH) {
    return process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH
  }

  return chromeCandidates.find((candidate) => fs.existsSync(candidate))
}

function terminateServer(server) {
  if (process.platform === 'win32' && server.pid) {
    spawnSync('taskkill', ['/PID', String(server.pid), '/T', '/F'], {
      stdio: 'ignore',
    })
    return
  }

  server.kill('SIGTERM')
}

function newContext(browser, viewport) {
  const { isMobile = false, ...size } = viewport
  return browser.newContext({
    viewport: size,
    isMobile,
    deviceScaleFactor: 1,
  })
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}
