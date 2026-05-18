# Security Policy

The Crab Super App team takes security seriously. Thanks for helping us keep the platform and its users safe.

## Supported Versions

Only the latest release on the `main` branch currently receives security updates. Once stable releases are tagged, this section will list the supported version range.

| Version | Supported          |
| ------- | ------------------ |
| `main` (latest) | :white_check_mark: |
| Older releases  | :x:                |

## Reporting a Vulnerability

**Do not open a public GitHub issue, pull request, or discussion for security vulnerabilities.**

Instead, email the maintainer directly:

- **Email**: `jasonbmt06@gmail.com`
- **Subject**: `[SECURITY] Crab Super App - <short description>`

Please include:

- A clear description of the issue and its impact
- Steps to reproduce, including any proof-of-concept code, requests, or payloads
- The affected service, endpoint, or component (e.g., `auth-service`, `gateway`, `mobile`)
- Your environment (commit SHA, deployment, OS / Flutter version)
- Whether the issue has been disclosed elsewhere

If you'd like to encrypt the report, request a PGP key in your initial email and we'll provide one.

## Response SLA

- **Acknowledgment**: within **48 hours** of receiving the report.
- **Triage and severity assessment**: within **5 business days**.
- **Fix timeline**: depends on severity:
  - **Critical** (RCE, auth bypass, secret leak, account takeover): patch within **7 days**
  - **High** (privilege escalation, IDOR, stored XSS): patch within **30 days**
  - **Medium / Low**: patch in the next regular release cycle

We will keep you updated as we triage and remediate. If we ask for clarification, please respond promptly so we can keep the process moving.

## Disclosure Policy

We follow **coordinated disclosure**:

- We ask reporters to give us **up to 90 days** to ship a fix before public disclosure.
- Once a fix is released, we will publish a security advisory crediting the reporter (unless they prefer to remain anonymous).
- For critical issues that are being actively exploited, we may release an emergency patch and disclose immediately.

## Bug Bounty

A formal bug bounty program is **not currently offered**. We will publicly acknowledge contributors in release notes and the `SECURITY-HALL-OF-FAME.md` file once it exists.

## Scope

### In Scope

Vulnerabilities in any of the following are eligible for review:

- Authentication and session management (OTP, JWT, refresh tokens, device binding)
- Authorization (IDOR, privilege escalation, tenant isolation)
- Injection flaws (SQL, NoSQL, command, LDAP, template)
- Cross-site scripting (XSS) and CSRF
- Secret leaks in code, logs, error responses, or container images
- Server-side request forgery (SSRF)
- Remote code execution (RCE)
- Unsafe deserialization
- Cryptographic weaknesses in our own code (key reuse, weak algorithms, IV reuse)
- Business-logic flaws that allow abuse (e.g., wallet double-spend, promo redemption bypass, ride-fare manipulation)
- Mobile-specific issues (insecure local storage, certificate pinning bypass, deep-link hijacking) in the Flutter app

### Out of Scope

- Phishing, social engineering, or physical attacks against our team or users
- Denial-of-service attacks, volumetric or otherwise
- Missing security headers on documentation sites or marketing pages
- Vulnerabilities in third-party services we depend on (report those upstream)
- Self-XSS that requires the victim to paste payloads into their own browser
- Outdated software disclosure without a working exploit
- Issues already reported by another researcher
- Vulnerabilities requiring a rooted/jailbroken device or a malicious app already installed by the victim

## Encryption and Secrets Handling

- **In transit**: all production traffic uses TLS 1.2+. Internal service-to-service traffic inside the cluster uses mTLS where supported.
- **At rest**: sensitive PII (phone numbers, KYC documents, payment tokens) is encrypted at the database/object-store layer. Object storage uses server-side encryption.
- **Secrets**: never committed to the repository. Local development uses `.env` files (gitignored). Production uses Kubernetes Secrets and Docker secrets, sourced from the platform's secret manager. Rotation is handled per-environment.

If you discover a committed secret in the repository history, please report it via email so we can rotate it before public disclosure.

## Safe Harbor

We will not pursue legal action against researchers who:

- Make a good-faith effort to follow this policy
- Avoid privacy violations, data destruction, and service disruption
- Do not access, modify, or exfiltrate user data beyond what is needed to demonstrate the issue
- Give us a reasonable window to respond before public disclosure

Thanks for keeping Crab safe.
