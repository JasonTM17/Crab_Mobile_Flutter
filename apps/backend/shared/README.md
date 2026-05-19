# Crab Shared Package

Shared utilities, guards, decorators, and interceptors used across all backend services.

## Contents

- **Guards**: `JwtAuthGuard`, `RolesGuard`, `ThrottlerGuard`
- **Decorators**: `@CurrentUser()`, `@Roles()`, `@Public()`
- **Interceptors**: `TransformInterceptor`, `LoggingInterceptor`, `TimeoutInterceptor`
- **Filters**: `AllExceptionsFilter`, `ValidationExceptionFilter`
- **DTOs**: `PaginationDto`, `ApiResponseDto`
- **Utils**: `hashPassword`, `comparePassword`, `generateId`

## Usage

```typescript
import { JwtAuthGuard, CurrentUser, Roles } from '@crab/shared';
import { PaginationDto } from '@crab/shared/dto';
```
