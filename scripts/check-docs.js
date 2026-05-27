const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const docs = [
  'README.md',
  'docs/INDEX.md',
  'docs/PORTFOLIO_CASE_STUDY.md',
  'docs/PACKAGES.md',
  'docs/CI_CD.md',
  'docs/DEPLOYMENT.md',
  'docs/screenshots/README.md',
]

const requiredReferences = [
  {
    file: 'README.md',
    refs: [
      '<a id="english-overview"></a>',
      '<a id="tong-quan-tieng-viet"></a>',
      '## English Overview',
      '## Tổng Quan Tiếng Việt',
      'nguyenson1710/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-<service>',
      'docs/PORTFOLIO_CASE_STUDY.md',
      'docs/PACKAGES.md',
    ],
  },
  {
    file: 'docs/PACKAGES.md',
    refs: [
      'nguyenson1710/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-gateway',
    ],
  },
  {
    file: 'docs/PORTFOLIO_CASE_STUDY.md',
    refs: [
      'nguyenson1710/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-<service>',
      'pnpm run verify:portfolio',
    ],
  },
]

const requiredBilingualTables = [
  {
    file: 'README.md',
    headings: [
      '| Reviewer signal | What to look for | Evidence |',
      '| Tín hiệu review | Cần xem gì | Bằng chứng |',
      '| Area | English capability | Tính năng tiếng Việt |',
      '| Registry / Artifact | Public name | English purpose | Vai trò tiếng Việt |',
      '| Surface | Preview | English notes | Ghi chú tiếng Việt |',
      '| Document | English purpose | Mục đích tiếng Việt |',
    ],
  },
  {
    file: 'docs/INDEX.md',
    headings: ['[English README](../README.md#english-overview)', '[README Tiếng Việt](../README.md#tong-quan-tieng-viet)'],
  },
  {
    file: 'docs/PORTFOLIO_CASE_STUDY.md',
    headings: ['## Bilingual Reading Model / Mô Hình Đọc Song Ngữ'],
  },
]

const mojibakeNeedles = [
  'Ã',
  'Â',
  'á»',
  'áº',
  'Ä',
  'Æ',
  'â€',
  'â†',
  'â”',
  '\uFFFD',
]

let failures = 0

for (const relativePath of docs) {
  const content = read(relativePath)
  if (!content) {
    continue
  }

  assertNoMojibake(relativePath, content)
  assertBilingual(relativePath, content)
  assertLocalMarkdownTargets(relativePath, content)
}

for (const requirement of requiredReferences) {
  const content = read(requirement.file)
  for (const ref of requirement.refs) {
    if (!content.includes(ref)) {
      fail(`${requirement.file} must reference ${ref}`)
    }
  }
}

for (const requirement of requiredBilingualTables) {
  const content = read(requirement.file)
  for (const heading of requirement.headings) {
    if (!content.includes(heading)) {
      fail(`${requirement.file} must include explicit bilingual structure: ${heading}`)
    }
  }
}

if (failures > 0) {
  process.exit(1)
}

console.log('Documentation guardrails passed')

function read(relativePath) {
  const fullPath = path.join(root, relativePath)
  if (!fs.existsSync(fullPath)) {
    fail(`Missing documentation file: ${relativePath}`)
    return ''
  }
  return fs.readFileSync(fullPath, 'utf8')
}

function assertNoMojibake(relativePath, content) {
  for (const needle of mojibakeNeedles) {
    if (content.includes(needle)) {
      fail(`${relativePath} appears to contain mojibake marker: ${needle}`)
    }
  }
}

function assertBilingual(relativePath, content) {
  if (!/[A-Za-z]{4,}/.test(content)) {
    fail(`${relativePath} must include English content`)
  }

  if (!/[À-ỹĐđ]/u.test(content)) {
    fail(`${relativePath} must include Vietnamese content with proper UTF-8 diacritics`)
  }
}

function assertLocalMarkdownTargets(relativePath, content) {
  const dir = path.dirname(path.join(root, relativePath))
  const markdownLink = /!?\[[^\]]*]\(([^)\s]+)(?:\s+"[^"]*")?\)/g

  for (const match of content.matchAll(markdownLink)) {
    const target = match[1]
    if (
      target.startsWith('http://') ||
      target.startsWith('https://') ||
      target.startsWith('mailto:') ||
      target.startsWith('#')
    ) {
      continue
    }

    const withoutAnchor = target.split('#')[0]
    if (!withoutAnchor) {
      continue
    }

    const resolved = path.resolve(dir, decodeURIComponent(withoutAnchor))
    if (!resolved.startsWith(root)) {
      fail(`${relativePath} links outside repository: ${target}`)
      continue
    }

    if (!fs.existsSync(resolved)) {
      fail(`${relativePath} has missing local link or media target: ${target}`)
    }
  }
}

function fail(message) {
  console.error(message)
  failures += 1
}
