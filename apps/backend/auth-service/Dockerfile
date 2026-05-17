FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/auth-service/package.json ./apps/backend/auth-service/

RUN corepack enable && pnpm install --frozen-lockfile

COPY apps/backend/auth-service/ ./apps/backend/auth-service/
COPY tsconfig.base.json ./

RUN pnpm --filter @crab/auth-service build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/apps/backend/auth-service/dist ./dist
COPY --from=builder /app/apps/backend/auth-service/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3001

CMD ["node", "dist/main.js"]
