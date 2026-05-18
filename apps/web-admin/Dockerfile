# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY tsconfig.base.json ./
COPY packages ./packages
COPY apps/web-admin ./apps/web-admin
RUN pnpm install --frozen-lockfile
RUN pnpm --filter @crab/common-types build
RUN pnpm --filter web-admin build

FROM nginx:1.27-alpine AS runtime
RUN apk add --no-cache wget
COPY --from=builder /app/apps/web-admin/dist /usr/share/nginx/html
COPY apps/web-admin/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
