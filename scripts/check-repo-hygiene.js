const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const rootOnlyJunkPatterns = [
  /^\.tmp-mobile-.*\.log$/i,
  /^_tmp_.+/i,
  /^hs_err_pid\d+\.log$/i,
  /^replay_pid\d+\.log$/i,
]

let failures = 0

for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
  if (!entry.isFile()) continue

  for (const pattern of rootOnlyJunkPatterns) {
    if (pattern.test(entry.name)) {
      fail(`Remove local scratch/crash artifact from repository root: ${entry.name}`)
      break
    }
  }
}

if (failures > 0) {
  process.exit(1)
}

console.log('Repository hygiene guardrails passed')

function fail(message) {
  console.error(message)
  failures += 1
}
