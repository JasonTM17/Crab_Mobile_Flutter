# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@10.0.0 --activate
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY tsconfig.base.json ./
COPY packages ./packages
COPY apps/backend/shared ./apps/backend/shared
COPY apps/backend/ride-service ./apps/backend/ride-service
RUN pnpm install --frozen-lockfile
RUN pnpm --filter @crab/common-types build
RUN pnpm --filter @crab/backend-shared build
RUN pnpm --filter @crab/ride-service build

FROM node:20-alpine AS runtime
ARG VCS_REF=unknown
LABEL org.opencontainers.image.source="https://github.com/JasonTM17/Crab_Mobile_Flutter" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.revision=$VCS_REF
WORKDIR /app
RUN apk add --no-cache wget
RUN addgroup -S app && adduser -S app -G app
RUN corepack enable && corepack prepare pnpm@10.0.0 --activate
COPY --from=builder /app/package.json /app/pnpm-lock.yaml /app/pnpm-workspace.yaml ./
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/apps/backend/shared/package.json ./apps/backend/shared/package.json
COPY --from=builder /app/apps/backend/shared/dist ./apps/backend/shared/dist
COPY --from=builder /app/apps/backend/ride-service/package.json ./apps/backend/ride-service/package.json
COPY --from=builder /app/apps/backend/ride-service/dist ./apps/backend/ride-service/dist
RUN pnpm install --prod --frozen-lockfile
USER app
ENV NODE_ENV=production
ENV PORT=3003
EXPOSE 3003
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:3003/health || exit 1
CMD ["node", "apps/backend/ride-service/dist/main.js"]
