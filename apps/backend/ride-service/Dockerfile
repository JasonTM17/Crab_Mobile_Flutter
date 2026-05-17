FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/ride-service/package.json ./apps/backend/ride-service/

RUN corepack enable && pnpm install --frozen-lockfile

COPY apps/backend/ride-service/ ./apps/backend/ride-service/
COPY tsconfig.base.json ./

RUN pnpm --filter @crab/ride-service build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/apps/backend/ride-service/dist ./dist
COPY --from=builder /app/apps/backend/ride-service/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3003

CMD ["node", "dist/main.js"]
