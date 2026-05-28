const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const docs = [
  'README.md',
  'docs/INDEX.md',
  'docs/PORTFOLIO_CASE_STUDY.md',
  'docs/PACKAGES.md',
  'docs/QUICKSTART.md',
  'docs/CI_CD.md',
  'docs/DEPLOYMENT.md',
  'docs/ENVIRONMENT.md',
  'docs/DEPLOYMENT_DOCKER.md',
  'docs/DEPLOYMENT_KUBERNETES.md',
  'docs/OPERATIONS_RUNBOOK.md',
  'docs/TROUBLESHOOTING.md',
  'docs/screenshots/README.md',
]

const requiredReferences = [
  {
    file: 'README.md',
    refs: [
      'docs/assets/crab-logo.svg',
      'Crab Super App logo',
      '<!-- EN:START -->',
      '<!-- EN:END -->',
      '<!-- VI:START -->',
      '<!-- VI:END -->',
      '<a id="english-track"></a>',
      '<a id="vietnamese-track"></a>',
      '<a id="english-overview"></a>',
      '<a id="tong-quan-tieng-viet"></a>',
      '## English Track',
      '## Vietnamese Track',
      'nguyenson1710/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-<service>',
      'docs/PORTFOLIO_CASE_STUDY.md',
      'docs/PACKAGES.md',
    ],
  },
  {
    file: 'docs/INDEX.md',
    refs: [
      '<!-- INDEX-EN:START -->',
      '<!-- INDEX-EN:END -->',
      '<!-- INDEX-VI:START -->',
      '<!-- INDEX-VI:END -->',
      '## English Documentation Index',
      '## Vietnamese Documentation Index',
      '[English README](../README.md#english-track)',
      '[README tiếng Việt](../README.md#vietnamese-track)',
    ],
  },
  {
    file: 'docs/PACKAGES.md',
    refs: [
      '<!-- PACKAGES-EN:START -->',
      '<!-- PACKAGES-EN:END -->',
      '<!-- PACKAGES-VI:START -->',
      '<!-- PACKAGES-VI:END -->',
      '## English Packages And Release Artifacts',
      '## Vietnamese Packages And Release Artifacts',
      'nguyenson1710/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-gateway',
    ],
  },
  {
    file: 'docs/PORTFOLIO_CASE_STUDY.md',
    refs: [
      '<!-- CASE-STUDY-EN:START -->',
      '<!-- CASE-STUDY-EN:END -->',
      '<!-- CASE-STUDY-VI:START -->',
      '<!-- CASE-STUDY-VI:END -->',
      '## English Case Study',
      '## Vietnamese Case Study',
      'nguyenson1710/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-<service>',
      'pnpm run verify:portfolio',
    ],
  },
  {
    file: 'docs/screenshots/README.md',
    refs: [
      '<!-- SCREENSHOTS-EN:START -->',
      '<!-- SCREENSHOTS-EN:END -->',
      '<!-- SCREENSHOTS-VI:START -->',
      '<!-- SCREENSHOTS-VI:END -->',
      '## English Screenshots Gallery',
      '## Vietnamese Screenshots Gallery',
      'admin-02-dashboard.png',
      'mobile-client-05-wallet-profile.png',
      '../gifs/mobile-client-flow.gif',
    ],
  },
  {
    file: 'docs/DEPLOYMENT.md',
    refs: [
      '<!-- DEPLOYMENT-EN:START -->',
      '<!-- DEPLOYMENT-EN:END -->',
      '<!-- DEPLOYMENT-VI:START -->',
      '<!-- DEPLOYMENT-VI:END -->',
      '## English Deployment Guide',
      '## Vietnamese Deployment Guide',
      'nguyenson1710/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-<service>',
      'pnpm run verify:portfolio',
    ],
  },
  {
    file: 'docs/QUICKSTART.md',
    refs: [
      '<!-- QUICKSTART-EN:START -->',
      '<!-- QUICKSTART-EN:END -->',
      '<!-- QUICKSTART-VI:START -->',
      '<!-- QUICKSTART-VI:END -->',
      '## English Quickstart',
      '## Vietnamese Quickstart',
      'pnpm run verify:portfolio',
    ],
  },
  {
    file: 'docs/CI_CD.md',
    refs: [
      '<!-- CICD-EN:START -->',
      '<!-- CICD-EN:END -->',
      '<!-- CICD-VI:START -->',
      '<!-- CICD-VI:END -->',
      '## English CI/CD and Release',
      '## Vietnamese CI/CD and Release',
      'nguyenson1710/crab-mobile-<service>',
      'ghcr.io/jasontm17/crab-mobile-<service>',
    ],
  },
  {
    file: 'docs/ENVIRONMENT.md',
    refs: [
      '<!-- ENVIRONMENT-EN:START -->',
      '<!-- ENVIRONMENT-EN:END -->',
      '<!-- ENVIRONMENT-VI:START -->',
      '<!-- ENVIRONMENT-VI:END -->',
      '## English Environment Reference',
      '## Vietnamese Environment Reference',
      '.env.production.example',
    ],
  },
  {
    file: 'docs/DEPLOYMENT_DOCKER.md',
    refs: [
      '<!-- DOCKER-EN:START -->',
      '<!-- DOCKER-EN:END -->',
      '<!-- DOCKER-VI:START -->',
      '<!-- DOCKER-VI:END -->',
      '## English Docker Deployment',
      '## Vietnamese Docker Deployment',
      'docker compose --env-file .env.production.example -f docker-compose.prod.yml config',
    ],
  },
  {
    file: 'docs/DEPLOYMENT_KUBERNETES.md',
    refs: [
      '<!-- KUBERNETES-EN:START -->',
      '<!-- KUBERNETES-EN:END -->',
      '<!-- KUBERNETES-VI:START -->',
      '<!-- KUBERNETES-VI:END -->',
      '## English Kubernetes Deployment',
      '## Vietnamese Kubernetes Deployment',
      'infra/k8s/',
    ],
  },
  {
    file: 'docs/OPERATIONS_RUNBOOK.md',
    refs: [
      '<!-- RUNBOOK-EN:START -->',
      '<!-- RUNBOOK-EN:END -->',
      '<!-- RUNBOOK-VI:START -->',
      '<!-- RUNBOOK-VI:END -->',
      '## English Operations Runbook',
      '## Vietnamese Operations Runbook',
      'curl http://localhost:3000/health',
    ],
  },
  {
    file: 'docs/TROUBLESHOOTING.md',
    refs: [
      '<!-- TROUBLESHOOTING-EN:START -->',
      '<!-- TROUBLESHOOTING-EN:END -->',
      '<!-- TROUBLESHOOTING-VI:START -->',
      '<!-- TROUBLESHOOTING-VI:END -->',
      '## English Troubleshooting',
      '## Vietnamese Troubleshooting',
      'pnpm run contract:check',
    ],
  },
]

const requiredFiles = ['docs/assets/crab-logo.svg']

const separatedLanguageTracks = [
  {
    file: 'README.md',
    englishStart: '<!-- EN:START -->',
    englishEnd: '<!-- EN:END -->',
    vietnameseStart: '<!-- VI:START -->',
    vietnameseEnd: '<!-- VI:END -->',
    englishHeading: '## English Track',
    vietnameseHeading: '## Vietnamese Track',
  },
  {
    file: 'docs/INDEX.md',
    englishStart: '<!-- INDEX-EN:START -->',
    englishEnd: '<!-- INDEX-EN:END -->',
    vietnameseStart: '<!-- INDEX-VI:START -->',
    vietnameseEnd: '<!-- INDEX-VI:END -->',
    englishHeading: '## English Documentation Index',
    vietnameseHeading: '## Vietnamese Documentation Index',
  },
  {
    file: 'docs/PACKAGES.md',
    englishStart: '<!-- PACKAGES-EN:START -->',
    englishEnd: '<!-- PACKAGES-EN:END -->',
    vietnameseStart: '<!-- PACKAGES-VI:START -->',
    vietnameseEnd: '<!-- PACKAGES-VI:END -->',
    englishHeading: '## English Packages And Release Artifacts',
    vietnameseHeading: '## Vietnamese Packages And Release Artifacts',
  },
  {
    file: 'docs/PORTFOLIO_CASE_STUDY.md',
    englishStart: '<!-- CASE-STUDY-EN:START -->',
    englishEnd: '<!-- CASE-STUDY-EN:END -->',
    vietnameseStart: '<!-- CASE-STUDY-VI:START -->',
    vietnameseEnd: '<!-- CASE-STUDY-VI:END -->',
    englishHeading: '## English Case Study',
    vietnameseHeading: '## Vietnamese Case Study',
  },
  {
    file: 'docs/screenshots/README.md',
    englishStart: '<!-- SCREENSHOTS-EN:START -->',
    englishEnd: '<!-- SCREENSHOTS-EN:END -->',
    vietnameseStart: '<!-- SCREENSHOTS-VI:START -->',
    vietnameseEnd: '<!-- SCREENSHOTS-VI:END -->',
    englishHeading: '## English Screenshots Gallery',
    vietnameseHeading: '## Vietnamese Screenshots Gallery',
  },
  {
    file: 'docs/DEPLOYMENT.md',
    englishStart: '<!-- DEPLOYMENT-EN:START -->',
    englishEnd: '<!-- DEPLOYMENT-EN:END -->',
    vietnameseStart: '<!-- DEPLOYMENT-VI:START -->',
    vietnameseEnd: '<!-- DEPLOYMENT-VI:END -->',
    englishHeading: '## English Deployment Guide',
    vietnameseHeading: '## Vietnamese Deployment Guide',
  },
  {
    file: 'docs/QUICKSTART.md',
    englishStart: '<!-- QUICKSTART-EN:START -->',
    englishEnd: '<!-- QUICKSTART-EN:END -->',
    vietnameseStart: '<!-- QUICKSTART-VI:START -->',
    vietnameseEnd: '<!-- QUICKSTART-VI:END -->',
    englishHeading: '## English Quickstart',
    vietnameseHeading: '## Vietnamese Quickstart',
  },
  {
    file: 'docs/CI_CD.md',
    englishStart: '<!-- CICD-EN:START -->',
    englishEnd: '<!-- CICD-EN:END -->',
    vietnameseStart: '<!-- CICD-VI:START -->',
    vietnameseEnd: '<!-- CICD-VI:END -->',
    englishHeading: '## English CI/CD and Release',
    vietnameseHeading: '## Vietnamese CI/CD and Release',
  },
  {
    file: 'docs/ENVIRONMENT.md',
    englishStart: '<!-- ENVIRONMENT-EN:START -->',
    englishEnd: '<!-- ENVIRONMENT-EN:END -->',
    vietnameseStart: '<!-- ENVIRONMENT-VI:START -->',
    vietnameseEnd: '<!-- ENVIRONMENT-VI:END -->',
    englishHeading: '## English Environment Reference',
    vietnameseHeading: '## Vietnamese Environment Reference',
  },
  {
    file: 'docs/DEPLOYMENT_DOCKER.md',
    englishStart: '<!-- DOCKER-EN:START -->',
    englishEnd: '<!-- DOCKER-EN:END -->',
    vietnameseStart: '<!-- DOCKER-VI:START -->',
    vietnameseEnd: '<!-- DOCKER-VI:END -->',
    englishHeading: '## English Docker Deployment',
    vietnameseHeading: '## Vietnamese Docker Deployment',
  },
  {
    file: 'docs/DEPLOYMENT_KUBERNETES.md',
    englishStart: '<!-- KUBERNETES-EN:START -->',
    englishEnd: '<!-- KUBERNETES-EN:END -->',
    vietnameseStart: '<!-- KUBERNETES-VI:START -->',
    vietnameseEnd: '<!-- KUBERNETES-VI:END -->',
    englishHeading: '## English Kubernetes Deployment',
    vietnameseHeading: '## Vietnamese Kubernetes Deployment',
  },
  {
    file: 'docs/OPERATIONS_RUNBOOK.md',
    englishStart: '<!-- RUNBOOK-EN:START -->',
    englishEnd: '<!-- RUNBOOK-EN:END -->',
    vietnameseStart: '<!-- RUNBOOK-VI:START -->',
    vietnameseEnd: '<!-- RUNBOOK-VI:END -->',
    englishHeading: '## English Operations Runbook',
    vietnameseHeading: '## Vietnamese Operations Runbook',
  },
  {
    file: 'docs/TROUBLESHOOTING.md',
    englishStart: '<!-- TROUBLESHOOTING-EN:START -->',
    englishEnd: '<!-- TROUBLESHOOTING-EN:END -->',
    vietnameseStart: '<!-- TROUBLESHOOTING-VI:START -->',
    vietnameseEnd: '<!-- TROUBLESHOOTING-VI:END -->',
    englishHeading: '## English Troubleshooting',
    vietnameseHeading: '## Vietnamese Troubleshooting',
  },
]

const indexReferences = [
  '[English README](../README.md#english-track)',
  '[README tiếng Việt](../README.md#vietnamese-track)',
]

const mojibakeNeedles = [
  'Ãƒ',
  'Ã‚',
  'Ã¡Â»',
  'Ã¡Âº',
  'Ã„',
  'Ã†',
  'Ã¢â‚¬',
  'Ã¢â€ ',
  'Ã¢â€',
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

for (const relativePath of requiredFiles) {
  if (!fs.existsSync(path.join(root, relativePath))) {
    fail(`Missing required documentation asset: ${relativePath}`)
  }
}

for (const requirement of separatedLanguageTracks) {
  const content = read(requirement.file)
  assertSeparatedLanguageTracks(requirement.file, content, requirement)
  assertNoMixedLanguageHeadings(requirement.file, content)
  assertNoMixedLanguageTables(requirement.file, content)
}

const indexContent = read('docs/INDEX.md')
for (const ref of indexReferences) {
  if (!indexContent.includes(ref)) {
    fail(`docs/INDEX.md must keep the README language entrypoint: ${ref}`)
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

  if (!/[\u00C0-\u1EF9\u0110\u0111]/u.test(content)) {
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

function assertSeparatedLanguageTracks(relativePath, content, config) {
  const englishStart = content.indexOf(config.englishStart)
  const englishEnd = content.indexOf(config.englishEnd)
  const vietnameseStart = content.indexOf(config.vietnameseStart)
  const vietnameseEnd = content.indexOf(config.vietnameseEnd)

  if (englishStart === -1 || englishEnd === -1 || vietnameseStart === -1 || vietnameseEnd === -1) {
    fail(`${relativePath} must include explicit English and Vietnamese block markers`)
    return
  }

  if (!(englishStart < englishEnd && englishEnd < vietnameseStart && vietnameseStart < vietnameseEnd)) {
    fail(`${relativePath} must place the complete English block before the Vietnamese block`)
    return
  }

  const englishBlock = content.slice(englishStart, englishEnd)
  const vietnameseBlock = content.slice(vietnameseStart, vietnameseEnd)

  if (!englishBlock.includes(config.englishHeading)) {
    fail(`${relativePath} English block must include ${config.englishHeading}`)
  }

  if (!vietnameseBlock.includes(config.vietnameseHeading)) {
    fail(`${relativePath} Vietnamese block must include ${config.vietnameseHeading}`)
  }

  if (englishBlock.includes(config.vietnameseStart) || englishBlock.includes(config.vietnameseHeading)) {
    fail(`${relativePath} English block must not contain Vietnamese block markers or headings`)
  }

  if (vietnameseBlock.includes(config.englishStart) || vietnameseBlock.includes(config.englishHeading)) {
    fail(`${relativePath} Vietnamese block must not contain English block markers or headings`)
  }
}

function assertNoMixedLanguageHeadings(relativePath, content) {
  const mixedHeading = content
    .split(/\r?\n/)
    .find((line) => /^#{1,4}\s+.+\s\/\s.+$/.test(line))

  if (mixedHeading) {
    fail(`${relativePath} must not use mixed-language slash headings: ${mixedHeading}`)
  }
}

function assertNoMixedLanguageTables(relativePath, content) {
  const lines = content.split(/\r?\n/)
  const mixedTable = lines.find((line, index) => {
    const nextLine = lines[index + 1] || ''
    const isHeader = /^\|.*\|$/.test(line) && /^\|\s*:?-{3,}:?\s*\|/.test(nextLine)

    return isHeader && /^\|.*English.*(Vietnamese|Ti.ng Vi.t).*\|/i.test(line)
  })

  if (mixedTable) {
    fail(`${relativePath} must not use mixed English/Vietnamese table headers: ${mixedTable}`)
  }
}

function fail(message) {
  console.error(message)
  failures += 1
}
