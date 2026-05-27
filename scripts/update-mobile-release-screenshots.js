const { spawn, spawnSync } = require('node:child_process')
const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const mobileDir = path.join(root, 'apps', 'mobile')
const screenshotsDir = path.join(root, 'docs', 'screenshots')
const timeoutMs = Number(process.env.RELEASE_SCREENSHOT_TIMEOUT_MS ?? 60000)
const settleMs = Number(process.env.RELEASE_SCREENSHOT_SETTLE_MS ?? 1000)

const shots = [
  {
    file: 'mobile-01-onboarding.png',
    test: 'capture mobile onboarding release screenshot',
  },
  {
    file: 'mobile-client-01-login.png',
    test: 'capture mobile client login release screenshot',
  },
  {
    file: 'mobile-client-02-home.png',
    test: 'capture mobile client home release screenshot',
  },
  {
    file: 'mobile-client-03-ride-booking.png',
    test: 'capture mobile ride booking release screenshot',
  },
  {
    file: 'mobile-client-04-food.png',
    test: 'capture mobile food discovery release screenshot',
  },
  {
    file: 'mobile-client-05-wallet-profile.png',
    test: 'capture mobile wallet profile release screenshot',
  },
]

main().catch((error) => {
  console.error(error.message)
  process.exit(1)
})

async function main() {
  for (const shot of shots) {
    await updateShot(shot)
  }
}

async function updateShot(shot) {
  const filePath = path.join(screenshotsDir, shot.file)
  const before = getMtime(filePath)
  const child = spawn(
    process.execPath,
    [
      '../../scripts/run-mobile-tool.js',
      'flutter',
      'test',
      'test/release_media_screenshots_test.dart',
      '--plain-name',
      shot.test,
    ],
    {
      cwd: mobileDir,
      env: { ...process.env, UPDATE_RELEASE_SCREENSHOTS: 'true' },
      stdio: 'inherit',
      shell: false,
    },
  )

  let exited = false
  let exitCode = null
  child.on('exit', (code) => {
    exited = true
    exitCode = code
  })

  const started = Date.now()
  while (Date.now() - started < timeoutMs) {
    if (getMtime(filePath) > before) {
      await sleep(settleMs)
      if (!exited) killTree(child.pid)
      await waitForExit(child, 5000)
      console.log(`Updated ${path.relative(root, filePath)}`)
      return
    }

    if (exited) {
      if (getMtime(filePath) > before) {
        console.log(`Updated ${path.relative(root, filePath)}`)
        return
      }
      throw new Error(
        `Screenshot test exited with code ${exitCode} before updating ${shot.file}`,
      )
    }

    await sleep(250)
  }

  killTree(child.pid)
  await waitForExit(child, 5000)
  throw new Error(`Timed out before updating ${shot.file}`)
}

function getMtime(filePath) {
  try {
    return fs.statSync(filePath).mtimeMs
  } catch {
    return 0
  }
}

function killTree(pid) {
  if (!pid) return

  if (process.platform === 'win32') {
    spawnSync('taskkill', ['/pid', String(pid), '/t', '/f'], {
      stdio: 'ignore',
    })
  } else {
    try {
      process.kill(-pid, 'SIGTERM')
    } catch {
      try {
        process.kill(pid, 'SIGTERM')
      } catch {
        // Process already exited.
      }
    }
  }
}

function waitForExit(child, maxWaitMs) {
  if (child.exitCode !== null || child.signalCode !== null) {
    return Promise.resolve()
  }

  return new Promise((resolve) => {
    const timer = setTimeout(resolve, maxWaitMs)
    child.once('exit', () => {
      clearTimeout(timer)
      resolve()
    })
  })
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}
