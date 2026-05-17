FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/notification-service/package.json ./apps/backend/notification-service/

RUN corepack enable && pnpm install --frozen-lockfile

COPY apps/backend/notification-service/ ./apps/backend/notification-service/
COPY tsconfig.base.json ./

RUN pnpm --filter @crab/notification-service build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/apps/backend/notification-service/dist ./dist
COPY --from=builder /app/apps/backend/notification-service/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3007

CMD ["node", "dist/main.js"]
