# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@10.0.0 --activate
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY tsconfig.base.json ./
COPY packages ./packages
COPY apps/web-admin ./apps/web-admin
RUN pnpm install --frozen-lockfile
RUN pnpm --filter @crab/common-types build
RUN pnpm --filter @crab/web-admin build

FROM nginx:1.27-alpine AS runtime
ARG VCS_REF=unknown
LABEL org.opencontainers.image.source="https://github.com/JasonTM17/Crab_Mobile_Flutter" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.revision=$VCS_REF
RUN apk add --no-cache wget && \
    mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run /var/log/nginx
COPY --from=builder --chown=nginx:nginx /app/apps/web-admin/dist /usr/share/nginx/html
COPY --chown=nginx:nginx apps/web-admin/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
USER nginx
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:8080/health || exit 1
CMD ["nginx", "-g", "daemon off; pid /tmp/nginx.pid;"]
