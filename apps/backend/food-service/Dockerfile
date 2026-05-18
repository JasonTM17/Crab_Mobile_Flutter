FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/food-service/package.json ./apps/backend/food-service/

RUN corepack enable && pnpm install --frozen-lockfile

COPY apps/backend/food-service/ ./apps/backend/food-service/
COPY tsconfig.base.json ./

RUN pnpm --filter @crab/food-service build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/apps/backend/food-service/dist ./dist
COPY --from=builder /app/apps/backend/food-service/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3004

CMD ["node", "dist/main.js"]
