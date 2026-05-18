FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/ ./packages/
COPY apps/backend/chat-service/package.json ./apps/backend/chat-service/

RUN corepack enable && pnpm install --frozen-lockfile

COPY apps/backend/chat-service/ ./apps/backend/chat-service/
COPY tsconfig.base.json ./

RUN pnpm --filter @crab/chat-service build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/apps/backend/chat-service/dist ./dist
COPY --from=builder /app/apps/backend/chat-service/package.json ./
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3006

CMD ["node", "dist/main.js"]
