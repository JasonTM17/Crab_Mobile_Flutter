FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/gateway/package.json ./apps/backend/gateway/

RUN corepack enable && pnpm install --frozen-lockfile

COPY apps/backend/gateway/ ./apps/backend/gateway/
COPY tsconfig.base.json ./

RUN pnpm --filter @crab/gateway build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/apps/backend/gateway/dist ./dist
COPY --from=builder /app/apps/backend/gateway/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000

CMD ["node", "dist/main.js"]
