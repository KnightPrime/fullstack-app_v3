# --- Stage 1: Build the React Client ---
FROM node:20-alpine AS frontend-builder
WORKDIR /app
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm install
COPY frontend/ ./frontend/
RUN cd frontend && npm run build

# --- Stage 2: Bundle Server Environment ---
FROM node:20-alpine
WORKDIR /app

# Install native NGINX package dependencies inside alpine
RUN apk add --no-cache nginx

# FIXED: Ensure NGINX system directories exist for runtime workers
RUN mkdir -p /run/nginx /var/log/nginx

# Configure and deploy background services
COPY backend/package*.json ./backend/
RUN cd backend && npm install --only=production
COPY backend/ ./backend/

# Extract production compiled assets directly into the NGINX web root
COPY --from=frontend-builder /app/frontend/build /var/www/html
COPY nginx.conf /etc/nginx/http.d/default.conf

EXPOSE 80

# FIXED: Explicitly use absolute paths for the execution engine to avoid startup crashes
CMD ["sh", "-c", "node /app/backend/server.js & nginx -g 'daemon off;'"]

