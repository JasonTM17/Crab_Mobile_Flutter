const { spawnSync } = require('node:child_process')
const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const mobileDir = path.join(root, 'apps', 'mobile')
const [tool, ...args] = process.argv.slice(2)
const allowedTools = new Set(['dart', 'flutter'])

if (!tool || !allowedTools.has(tool)) {
  console.error('Usage: node scripts/run-mobile-tool.js <dart|flutter> [...args]')
  process.exit(1)
}

const env = { ...process.env }
const command = process.platform === 'win32' ? 'cmd.exe' : tool
const commandArgs = process.platform === 'win32' ? ['/d', '/s', '/c', tool, ...args] : args

if (process.platform === 'win32' && !env.LOCALAPPDATA) {
  env.LOCALAPPDATA = env.USERPROFILE
    ? path.join(env.USERPROFILE, 'AppData', 'Local')
    : path.join(mobileDir, '.dart_tool', 'local-app-data')
  fs.mkdirSync(env.LOCALAPPDATA, { recursive: true })
}

if (process.platform === 'win32' && !env.PUB_CACHE) {
  env.PUB_CACHE = path.join(env.LOCALAPPDATA, 'Pub', 'Cache')
  fs.mkdirSync(env.PUB_CACHE, { recursive: true })
}

const result = spawnSync(command, commandArgs, {
  cwd: mobileDir,
  env,
  stdio: 'inherit',
  shell: false,
})

if (result.error) {
  console.error(result.error.message)
  process.exit(1)
}

process.exit(result.status ?? 1)
