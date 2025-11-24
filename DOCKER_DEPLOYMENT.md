# Docker Deployment Configuration

## Setting the API URL for Production

The ProxiMate frontend can be configured to connect to different API backends using environment variables.

### Quick Start

1. **Create a `.env` file** (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file** with your production API URL:
   ```env
   API_BASE_URL=https://api.proximate.app
   ENVIRONMENT=production
   ```

3. **Build and run with Docker Compose**:
   ```bash
   docker compose up --build
   ```

### Configuration Options

#### API_BASE_URL
The backend API endpoint URL. Examples:
- **Local development**: `http://localhost:8000`
- **Docker network**: `http://backend:8000` (if backend is in same docker network)
- **Production**: `https://api.proximate.app`

#### ENVIRONMENT
- `development` - Development mode with debug logging
- `production` - Production mode with optimizations

### Build Without Docker Compose

You can also pass the API URL directly when building:

```bash
docker build \
  --build-arg API_BASE_URL=https://api.proximate.app \
  --build-arg ENVIRONMENT=production \
  -t proximate-web:latest .
```

### Run Container

```bash
docker run -d \
  --name proximate-web \
  -p 8300:80 \
  proximate-web:latest
```

### Verify Configuration

After deployment, the app will connect to the API URL specified during build time. You can verify by checking browser console logs when the app loads.

### Multiple Environments

For different environments, you can create separate `.env` files:

- `.env.development` - Local development
- `.env.staging` - Staging environment  
- `.env.production` - Production environment

Then specify which to use:

```bash
docker compose --env-file .env.production up --build
```
