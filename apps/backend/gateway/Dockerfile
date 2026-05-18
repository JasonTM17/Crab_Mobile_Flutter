# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY tsconfig.base.json ./
COPY packages ./packages
COPY apps/backend/gateway ./apps/backend/gateway
RUN pnpm install --frozen-lockfile
RUN pnpm --filter @crab/common-types build
RUN pnpm --filter @crab/gateway build

FROM node:20-alpine AS runtime
WORKDIR /app
RUN apk add --no-cache wget
RUN addgroup -S app && adduser -S app -G app
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate
COPY --from=builder /app/package.json /app/pnpm-lock.yaml /app/pnpm-workspace.yaml ./
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps/backend/gateway/package.json ./apps/backend/gateway/package.json
COPY --from=builder /app/apps/backend/gateway/dist ./apps/backend/gateway/dist
RUN pnpm install --prod --frozen-lockfile
USER app
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "apps/backend/gateway/dist/main.js"]
