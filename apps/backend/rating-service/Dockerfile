FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/rating-service/package.json ./apps/backend/rating-service/

RUN corepack enable && pnpm install --frozen-lockfile

COPY apps/backend/rating-service/ ./apps/backend/rating-service/
COPY tsconfig.base.json ./

RUN pnpm --filter @crab/rating-service build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/apps/backend/rating-service/dist ./dist
COPY --from=builder /app/apps/backend/rating-service/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3008

CMD ["node", "dist/main.js"]
