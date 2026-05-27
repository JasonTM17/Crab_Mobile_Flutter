const { spawnSync } = require('node:child_process')
const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const defaultScript = 'tests/load/baseline-smoke.js'
const k6Scripts = (process.env.CRAB_LOAD_SCRIPTS || 'tests/load/baseline-smoke.js')
  .split(',')
  .map((item) => item.trim())
  .filter(Boolean)

main().catch((error) => {
  console.error(error.message || error)
  process.exit(1)
})

async function main() {
  const k6Command = findK6Command()
  if (k6Command) {
    runK6Scripts(k6Command)
    return
  }

  if (!canUseNodeBaseline(k6Scripts)) {
    console.error(
      'k6 is required for non-baseline load scripts. Install k6 v0.50+ or run the default baseline with pnpm run test:load.',
    )
    process.exit(1)
  }

  await runNodeBaseline()
}

function runK6Scripts(k6Command) {
  for (const script of k6Scripts) {
    const scriptPath = path.resolve(root, script)
    console.log(`Running k6 load script: ${path.relative(root, scriptPath)}`)
    const result = spawnSync(k6Command, ['run', scriptPath], {
      cwd: root,
      stdio: 'inherit',
      env: {
        ...process.env,
        BASE_URL: process.env.BASE_URL || 'http://localhost:3000',
        LOGIN_EMAIL: process.env.LOGIN_EMAIL || 'rider@crab.app',
        LOGIN_PASSWORD: process.env.LOGIN_PASSWORD || 'User123!',
      },
    })
    if ((result.status ?? 1) !== 0) {
      process.exit(result.status ?? 1)
    }
  }
}

async function runNodeBaseline() {
  const baseUrl = (process.env.BASE_URL || 'http://localhost:3000').replace(/\/+$/, '')
  const vus = readPositiveInt('CRAB_LOAD_VUS', 1)
  const durationMs = readPositiveInt('CRAB_LOAD_DURATION_MS', 5_000)
  const p99LimitMs = readPositiveInt('CRAB_LOAD_P99_MS', 500)
  const timeoutMs = readPositiveInt('CRAB_LOAD_TIMEOUT_MS', 2_000)
  const endpoints = [
    {
      name: 'gateway_health',
      path: '/health',
      validate: (json) => json.status === 'ok',
    },
    {
      name: 'proxy_health',
      path: '/api/v1/proxy/health',
      validate: (json) => json.gateway === 'ok',
    },
  ]

  console.log(`k6 not found; running Node baseline fallback for ${defaultScript}`)
  console.log(
    `Node load baseline: base=${baseUrl} vus=${vus} duration=${durationMs}ms p99<=${p99LimitMs}ms`,
  )

  const preflight = await runNodeIteration(baseUrl, endpoints, timeoutMs)
  if (preflight.failures > 0) {
    console.error(
      `Node load baseline preflight failed. Ensure the local gateway is running at ${baseUrl}.`,
    )
    for (const error of preflight.errors) {
      console.error(`- ${error}`)
    }
    process.exit(1)
  }

  const deadline = Date.now() + durationMs
  const workers = Array.from({ length: vus }, () =>
    runNodeWorker(baseUrl, endpoints, timeoutMs, deadline),
  )
  const results = await Promise.all(workers)
  const summary = combineResults([preflight, ...results])
  const p99 = percentile(summary.durations, 99)

  console.log(
    `Node load baseline completed: requests=${summary.requests}, failures=${summary.failures}, p99=${p99}ms`,
  )

  if (summary.failures > 0 || p99 > p99LimitMs) {
    for (const error of summary.errors.slice(0, 10)) {
      console.error(`- ${error}`)
    }
    console.error(
      `Node load baseline failed: failures must be 0 and p99 must be <= ${p99LimitMs}ms.`,
    )
    process.exit(1)
  }
}

async function runNodeWorker(baseUrl, endpoints, timeoutMs, deadline) {
  const result = emptyResult()
  while (Date.now() < deadline) {
    const iteration = await runNodeIteration(baseUrl, endpoints, timeoutMs)
    mergeResult(result, iteration)
    await sleep(1_000)
  }
  return result
}

async function runNodeIteration(baseUrl, endpoints, timeoutMs) {
  const result = emptyResult()
  for (const endpoint of endpoints) {
    const startedAt = Date.now()
    try {
      const response = await fetch(`${baseUrl}${endpoint.path}`, {
        signal: AbortSignal.timeout(timeoutMs),
      })
      const text = await response.text()
      const duration = Date.now() - startedAt
      let json = {}
      try {
        json = text ? JSON.parse(text) : {}
      } catch (_error) {
        result.errors.push(`${endpoint.name}: response is not JSON`)
      }

      result.requests += 1
      result.durations.push(duration)

      if (!response.ok || !endpoint.validate(json)) {
        result.failures += 1
        result.errors.push(`${endpoint.name}: expected healthy JSON response, got ${response.status}`)
      }
    } catch (error) {
      result.requests += 1
      result.failures += 1
      result.durations.push(Date.now() - startedAt)
      result.errors.push(`${endpoint.name}: ${error.message || error}`)
    }
  }
  return result
}

function canUseNodeBaseline(scripts) {
  return scripts.length === 1 && normalizeScript(scripts[0]) === defaultScript
}

function normalizeScript(script) {
  return path.relative(root, path.resolve(root, script)).replace(/\\/g, '/')
}

function findK6Command() {
  if (commandExists('k6')) {
    return 'k6'
  }

  if (process.platform === 'win32') {
    const candidates = [
      'C:\\Program Files\\k6\\k6.exe',
      'C:\\Program Files (x86)\\k6\\k6.exe',
    ]
    return candidates.find((candidate) => fs.existsSync(candidate)) || null
  }

  return null
}

function commandExists(command) {
  const checker = process.platform === 'win32' ? 'where.exe' : 'which'
  const result = spawnSync(checker, [command], { stdio: 'ignore' })
  return result.status === 0
}

function readPositiveInt(name, fallback) {
  const value = Number.parseInt(process.env[name] || '', 10)
  return Number.isFinite(value) && value > 0 ? value : fallback
}

function emptyResult() {
  return {
    requests: 0,
    failures: 0,
    durations: [],
    errors: [],
  }
}

function combineResults(results) {
  return results.reduce((combined, result) => mergeResult(combined, result), emptyResult())
}

function mergeResult(target, source) {
  target.requests += source.requests
  target.failures += source.failures
  target.durations.push(...source.durations)
  target.errors.push(...source.errors)
  return target
}

function percentile(values, percentileRank) {
  if (values.length === 0) {
    return 0
  }
  const sorted = [...values].sort((a, b) => a - b)
  const index = Math.min(
    sorted.length - 1,
    Math.max(0, Math.ceil((percentileRank / 100) * sorted.length) - 1),
  )
  return sorted[index]
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}
