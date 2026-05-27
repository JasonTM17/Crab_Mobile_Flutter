const { spawnSync } = require('node:child_process')
const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const scripts = {
  migrate: path.join(root, 'scripts', 'schema.sql'),
  seed: path.join(root, 'scripts', 'seed.sql'),
}

const mode = process.argv[2]
if (!scripts[mode]) {
  console.error('Usage: node scripts/run-db-script.js <migrate|seed>')
  process.exit(1)
}

const sqlFile = scripts[mode]
if (!fs.existsSync(sqlFile)) {
  console.error(`Missing SQL file: ${path.relative(root, sqlFile)}`)
  process.exit(1)
}

const envFile = resolveEnvFile()
const envFromFile = readEnvFile(envFile)
const dbUser = process.env.POSTGRES_USER || envFromFile.POSTGRES_USER || 'crab'
const dbName = process.env.POSTGRES_DB || envFromFile.POSTGRES_DB || 'crab_db'
const databaseUrl = process.env.DATABASE_URL || envFromFile.DATABASE_URL

if (databaseUrl && commandExists('psql')) {
  runLocalPsql(databaseUrl, sqlFile)
} else {
  runDockerPsql(sqlFile, envFile, dbUser, dbName)
}

function runLocalPsql(url, file) {
  console.log(`Running ${path.relative(root, file)} via local psql`)
  const result = spawnSync('psql', [url, '-v', 'ON_ERROR_STOP=1', '-f', file], {
    stdio: 'inherit',
  })
  process.exit(result.status ?? 1)
}

function runDockerPsql(file, composeEnvFile, user, database) {
  if (!commandExists('docker')) {
    console.error('Docker is required when psql/DATABASE_URL is not available.')
    process.exit(1)
  }

  const sql = fs.readFileSync(file, 'utf8')
  const composeFile = path.join(root, 'docker-compose.prod.yml')
  const args = [
    'compose',
    '--env-file',
    composeEnvFile,
    '-f',
    composeFile,
    'exec',
    '-T',
    'postgres',
    'psql',
    '-U',
    user,
    '-d',
    database,
    '-v',
    'ON_ERROR_STOP=1',
  ]

  console.log(`Running ${path.relative(root, file)} inside the postgres container`)
  const result = spawnSync('docker', args, {
    input: sql,
    stdio: ['pipe', 'inherit', 'inherit'],
  })

  if (result.error) {
    console.error(result.error.message)
    process.exit(1)
  }
  process.exit(result.status ?? 1)
}

function resolveEnvFile() {
  const requested = process.env.CRAB_ENV_FILE
  if (requested) return path.resolve(root, requested)

  const production = path.join(root, '.env.production')
  if (fs.existsSync(production)) return production

  return path.join(root, '.env.production.example')
}

function readEnvFile(file) {
  if (!fs.existsSync(file)) return {}

  return fs
    .readFileSync(file, 'utf8')
    .split(/\r?\n/)
    .reduce((env, line) => {
      const trimmed = line.trim()
      if (!trimmed || trimmed.startsWith('#')) return env
      const index = trimmed.indexOf('=')
      if (index === -1) return env
      const key = trimmed.slice(0, index).trim()
      let value = trimmed.slice(index + 1).trim()
      if (
        (value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))
      ) {
        value = value.slice(1, -1)
      }
      env[key] = value
      return env
    }, {})
}

function commandExists(command) {
  const checker = process.platform === 'win32' ? 'where.exe' : 'which'
  const result = spawnSync(checker, [command], { stdio: 'ignore' })
  return result.status === 0
}
