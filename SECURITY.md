# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x.x   | Yes       |
| < 1.0   | No        |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do NOT** open a public GitHub issue
2. Email: jasonbmt06@gmail.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

You will receive a response within 48 hours acknowledging receipt.

## Security Measures

### Authentication & Authorization

- JWT-based authentication with short-lived access tokens (15 min)
- Refresh token rotation with single-use enforcement
- bcrypt password hashing (12 salt rounds)
- Role-based access control (RBAC): rider, driver, restaurant_owner, admin
- OAuth2 support for social login (Google, Facebook)

### API Security

- Rate limiting: 100 req/min per IP, 1000 req/min per authenticated user
- Input validation via class-validator on all DTOs
- Request size limits (10MB max body)
- CORS configured per environment (whitelist-based)
- Helmet.js for HTTP security headers:
  - X-Content-Type-Options: nosniff
  - X-Frame-Options: DENY
  - X-XSS-Protection: 1; mode=block
  - Strict-Transport-Security (production)
  - Content-Security-Policy

### Data Protection

- Passwords never stored in plaintext
- Sensitive fields excluded from API responses (password_hash, token_hash)
- Database connections use TLS in production
- Environment variables for all secrets (never committed)
- `.env` files in `.gitignore`

### Infrastructure

- Docker containers run as non-root user
- Network isolation between services (Docker networks)
- Health check endpoints do not expose internal state
- Graceful shutdown handling prevents data corruption
- Redis AUTH enabled in production

### WebSocket Security

- Token-based authentication on connection
- Event payload validation
- Per-event rate limiting
- Automatic disconnection on token expiry
- No sensitive data in event payloads

### Payment Security

- Wallet balance protected by database transactions (SERIALIZABLE isolation)
- Double-spend prevention via optimistic locking
- Payment method tokens stored encrypted
- Audit trail for all financial transactions
- Refund requires admin approval for amounts > 500,000 VND

### Mobile App Security

- Flutter Secure Storage for token persistence
- Certificate pinning for API calls (production)
- No sensitive data in app logs
- Biometric authentication support
- App transport security (ATS) enforced

## Dependencies

- Dependencies are pinned to exact versions
- Automated security scanning via GitHub Dependabot
- Regular dependency audits (`pnpm audit`)

## Incident Response

1. Identify and contain the vulnerability
2. Assess impact and affected users
3. Deploy fix to production
4. Notify affected users if data was compromised
5. Post-mortem and prevention measures
