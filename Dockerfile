# syntax=docker/dockerfile:1

# ---- Build stage: generate the static site ----
FROM node:22-alpine AS builder
WORKDIR /app/docs
COPY docs/package.json docs/package-lock.json ./
RUN npm ci --omit=dev
COPY docs ./
RUN npm run build

# ---- Run stage: serve the static site with nginx ----
FROM nginx:1.25-alpine AS runner
COPY --from=builder /app/docs/dist /usr/share/nginx/html
COPY deploy/container-nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
