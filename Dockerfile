# Multi-stage build for minimal final image size
# Stage 1: Build the Flutter web app
FROM instrumentisto/flutter:latest AS build

# Build argument for API URL (defaults to localhost for development)
ARG API_BASE_URL=http://localhost:8000
ARG ENVIRONMENT=production

# Set working directory
WORKDIR /app

# Copy pubspec files first for better caching
COPY pubspec.yaml pubspec.lock ./

# Copy generated OpenAPI client (required dependency)
COPY gen/ ./gen/

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build web app with optimizations and environment variables
# --release: Production build with minification
# --dart-define: Pass environment variables to Flutter
# Default renderer works across all browsers (Chrome, Firefox, Safari, Edge)
RUN flutter build web --release \
    --dart-define=API_BASE_URL=$API_BASE_URL \
    --dart-define=ENVIRONMENT=$ENVIRONMENT

# Stage 2: Serve with nginx (minimal image)
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Add labels for metadata
LABEL maintainer="ProxiMate Team"
LABEL description="ProxiMate - Peer Networking Flutter Web App"
LABEL version="1.0.0"

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
