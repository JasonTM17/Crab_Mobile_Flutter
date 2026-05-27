const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const expectedPackages = [
  'package.json',
  'packages/common-types/package.json',
  'packages/socket-events/package.json',
  'apps/backend/shared/package.json',
  'apps/backend/gateway/package.json',
  'apps/backend/auth-service/package.json',
  'apps/backend/user-service/package.json',
  'apps/backend/ride-service/package.json',
  'apps/backend/food-service/package.json',
  'apps/backend/payment-service/package.json',
  'apps/backend/chat-service/package.json',
  'apps/backend/notification-service/package.json',
  'apps/backend/rating-service/package.json',
  'apps/web-admin/package.json',
  'apps/mobile/package.json',
]

let failures = 0

for (const relativePath of expectedPackages) {
  const fullPath = path.join(root, relativePath)
  if (!fs.existsSync(fullPath)) {
    fail(`Missing package metadata: ${relativePath}`)
    continue
  }

  const pkg = JSON.parse(fs.readFileSync(fullPath, 'utf8'))
  expectString(pkg.name, `${relativePath} name`)
  expectString(pkg.version, `${relativePath} version`)
  expectString(pkg.description, `${relativePath} description`)

  if (pkg.private !== true) {
    fail(`${relativePath} must be private because this monorepo does not publish npm packages`)
  }

  if (relativePath !== 'package.json') {
    expectObject(pkg.scripts, `${relativePath} scripts`)
  }
}

const docsToCheck = [
  'README.md',
  'docs/CI_CD.md',
  'docs/DEPLOYMENT.md',
  'docs/INDEX.md',
  'docs/PACKAGES.md',
]

for (const relativePath of docsToCheck) {
  const content = read(relativePath)
  if (!content.includes('nguyenson1710/crab-mobile-')) {
    fail(`${relativePath} must document the canonical Docker namespace`)
  }
  if (!content.includes('ghcr.io/jasontm17/crab-mobile-')) {
    fail(`${relativePath} must document the GitHub Packages/GHCR namespace`)
  }
}

const dockerPublishWorkflow = read('.github/workflows/docker-publish.yml')
if (!dockerPublishWorkflow.includes('packages: write')) {
  fail('.github/workflows/docker-publish.yml must grant packages: write for GHCR publishing')
}
if (!dockerPublishWorkflow.includes('ghcr.io')) {
  fail('.github/workflows/docker-publish.yml must publish GitHub Packages/GHCR images')
}

const screenshotsReadme = read('docs/screenshots/README.md')
for (const image of [
  'mobile-01-onboarding.png',
  'mobile-client-01-login.png',
  'mobile-client-02-home.png',
  'mobile-client-03-ride-booking.png',
  'mobile-client-04-food.png',
  'mobile-client-05-wallet-profile.png',
]) {
  if (!screenshotsReadme.includes(image)) {
    fail(`docs/screenshots/README.md must reference ${image}`)
  }
  if (!fs.existsSync(path.join(root, 'docs/screenshots', image))) {
    fail(`Missing release screenshot: docs/screenshots/${image}`)
  }
}

const mobileGif = 'mobile-client-flow.gif'
if (!screenshotsReadme.includes(mobileGif)) {
  fail(`docs/screenshots/README.md must reference ${mobileGif}`)
}
if (!fs.existsSync(path.join(root, 'docs/gifs', mobileGif))) {
  fail(`Missing release GIF: docs/gifs/${mobileGif}`)
}

for (const relativePath of [
  'README.md',
  'docs/MOBILE.md',
  'docs/screenshots/README.md',
]) {
  assertNoScratchMediaReferences(relativePath, read(relativePath))
}

if (failures > 0) {
  process.exit(1)
}

console.log('Package and release artifact guardrails passed')

function read(relativePath) {
  const fullPath = path.join(root, relativePath)
  if (!fs.existsSync(fullPath)) {
    fail(`Missing file: ${relativePath}`)
    return ''
  }
  return fs.readFileSync(fullPath, 'utf8')
}

function expectString(value, label) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    fail(`${label} must be a non-empty string`)
  }
}

function expectObject(value, label) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    fail(`${label} must be an object`)
  }
}

function assertNoScratchMediaReferences(relativePath, content) {
  const scratchMediaReference =
    /!?\[[^\]]*]\([^)]*(?:docs\/)?(?:screenshots|gifs)\/[^)]*(?:proof|current|emulator|tmp)[^)]*\)/gi
  const matches = content.match(scratchMediaReference)
  if (matches) {
    fail(`${relativePath} must not embed local scratch media: ${matches.join(', ')}`)
  }
}

function fail(message) {
  console.error(message)
  failures += 1
}
