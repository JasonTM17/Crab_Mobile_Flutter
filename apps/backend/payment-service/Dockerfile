FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/payment-service/package.json ./apps/backend/payment-service/

RUN corepack enable && pnpm install --frozen-lockfile

COPY apps/backend/payment-service/ ./apps/backend/payment-service/
COPY tsconfig.base.json ./

RUN pnpm --filter @crab/payment-service build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/apps/backend/payment-service/dist ./dist
COPY --from=builder /app/apps/backend/payment-service/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3005

CMD ["node", "dist/main.js"]
