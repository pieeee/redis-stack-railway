# Redis Stack Docker Setup

This repository contains Docker configuration for running Redis Stack with environment-based configuration. It's designed to work both locally with Docker Compose and as a Railway template.

## Files

- `Dockerfile` - Docker configuration for Redis Stack
- `docker-compose.yml` - Docker Compose configuration for local development
- `railway.json` - Railway template configuration
- `env.sample` - Sample environment variables (copy to `.env`)

## Quick Start

1. **Copy the environment file:**

   ```bash
   cp env.sample .env
   ```

2. **Edit the `.env` file with your configuration:**

   ```bash
   # Update these values in .env
   REDIS_USERNAME=your_username
   REDIS_PASSWORD=your_secure_password
   REDIS_DB=0
   REDIS_PORT=6379
   ```

3. **Build and run with Docker Compose:**
   ```bash
   docker-compose up -d
   ```

### Railway Deployment

1. **Deploy to Railway:**

   ```bash
   # Install Railway CLI
   npm install -g @railway/cli

   # Login to Railway
   railway login

   # Deploy the project
   railway up
   ```

2. **Set environment variables in Railway dashboard:**

   - Go to your project in Railway dashboard
   - Navigate to Variables tab
   - Add the required environment variables:
     - `REDIS_PASSWORD` (required)
     - `REDIS_USERNAME` (optional, defaults to "default")
     - `REDIS_DB` (optional, defaults to "0")
     - `REDIS_PORT` (optional, defaults to "6379")

3. **Access your Redis Stack:**
   - Railway will provide you with a public URL
   - Redis will be available on the configured port
   - Redis Stack UI will be available on port 8001

## Manual Docker Commands

If you prefer to use Docker directly:

1. **Build the image:**

   ```bash
   docker build -t redis-stack-custom .
   ```

2. **Run the container:**
   ```bash
   docker run -d \
     --name redis-stack \
     -p 6379:6379 \
     -p 8001:8001 \
     -e REDIS_USERNAME=your_username \
     -e REDIS_PASSWORD=your_password \
     -e REDIS_DB=0 \
     -e REDIS_PORT=6379 \
     redis-stack-custom
   ```

## Access

- **Redis CLI:** `redis-cli -h localhost -p 6379 -a your_password`
- **Redis Stack UI:** http://localhost:8001
- **Redis Insight:** Available in the UI for database management

## Environment Variables

| Variable              | Default    | Description           |
| --------------------- | ---------- | --------------------- |
| `REDIS_USERNAME`      | `default`  | Redis username        |
| `REDIS_PASSWORD`      | `changeme` | Redis password        |
| `REDIS_DB`            | `0`        | Redis database number |
| `REDIS_PORT`          | `6379`     | Redis port            |
| `REDIS_STACK_UI_PORT` | `8001`     | Redis Stack UI port   |

## Features

- ✅ Latest Redis Stack image
- ✅ Environment-based configuration
- ✅ Health checks
- ✅ Persistent data volume (Railway volume)
- ✅ Redis Stack UI included
- ✅ Custom Redis configuration
- ✅ Docker Compose support
- ✅ Railway template ready
- ✅ Railway CLI deployment support
- ✅ AOF persistence enabled

## Security Notes

- Always change the default password in production
- Use strong, unique passwords
- Consider using Docker secrets for sensitive data in production
- Restrict network access as needed
