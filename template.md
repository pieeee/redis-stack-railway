# Redis Stack Template

A production-ready Redis Stack deployment template for Railway.

## What's Included

- **Redis Stack Latest**: Complete Redis database with RedisJSON, RedisSearch, RedisGraph, and RedisTimeSeries modules
- **Redis Insight UI**: Web-based database management interface
- **Environment Configuration**: Secure password and database configuration via environment variables
- **Health Checks**: Built-in health monitoring
- **Persistent Storage**: Railway volume for data persistence
- **AOF Persistence**: Append-only file persistence for data durability

## Quick Deploy

1. Click "Deploy to Railway" or use the Railway CLI
2. Set your `REDIS_PASSWORD` environment variable
3. Deploy and get your Redis connection details

## Features

- 🔐 **Secure**: Password-protected Redis instance
- 🚀 **Fast**: Latest Redis Stack with all modules
- 📊 **Manageable**: Built-in Redis Insight UI
- 🔧 **Configurable**: Environment-based configuration
- 📈 **Scalable**: Ready for production workloads

## Environment Variables

- `REDIS_PASSWORD` (required): Your Redis password
- `REDIS_USERNAME` (optional): Redis username (default: "default")
- `REDIS_DB` (optional): Database number (default: 0)
- `REDIS_PORT` (optional): Redis port (default: 6379)

## Use Cases

- Application caching
- Session storage
- Real-time data processing
- Graph databases
- Time series data
- Full-text search
- JSON document storage
