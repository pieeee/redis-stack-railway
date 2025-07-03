# Use Redis Stack latest image
FROM redis/redis-stack:latest

# Environment variables (no defaults - users must provide these)
# REDIS_USERNAME - Redis username
# REDIS_PASSWORD - Redis password (required)
# REDIS_PORT - Redis port (required)
# REDIS_DATA_DIR - Data directory path for volume mounting (required)
# REDIS_SAVE_INTERVAL - Save intervals (optional, defaults to standard intervals)
# REDIS_MAX_MEMORY - Max memory limit (optional)
# REDIS_MAX_MEMORY_POLICY - Memory eviction policy (optional)

# Install additional tools for health check
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create data directory (will be overridden by user's volume mount)
RUN mkdir -p /data

# Create a startup script that handles environment variable substitution
RUN echo '#!/bin/bash' > /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo '# Validate required environment variables' >> /usr/local/bin/start-redis.sh && \
    echo 'if [ -z "$REDIS_PASSWORD" ]; then' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "Error: REDIS_PASSWORD environment variable is required"' >> /usr/local/bin/start-redis.sh && \
    echo '  exit 1' >> /usr/local/bin/start-redis.sh && \
    echo 'fi' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo 'if [ -z "$REDIS_PORT" ]; then' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "Error: REDIS_PORT environment variable is required"' >> /usr/local/bin/start-redis.sh && \
    echo '  exit 1' >> /usr/local/bin/start-redis.sh && \
    echo 'fi' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo 'if [ -z "$REDIS_DATA_DIR" ]; then' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "Error: REDIS_DATA_DIR environment variable is required"' >> /usr/local/bin/start-redis.sh && \
    echo '  exit 1' >> /usr/local/bin/start-redis.sh && \
    echo 'fi' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo '# Create the data directory if it does not exist' >> /usr/local/bin/start-redis.sh && \
    echo 'mkdir -p "$REDIS_DATA_DIR"' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo '# Create redis.conf with environment variable substitution' >> /usr/local/bin/start-redis.sh && \
    echo 'cat > /usr/local/etc/redis/redis.conf << EOL' >> /usr/local/bin/start-redis.sh && \
    echo 'requirepass ${REDIS_PASSWORD}' >> /usr/local/bin/start-redis.sh && \
    echo 'port ${REDIS_PORT}' >> /usr/local/bin/start-redis.sh && \
    echo 'databases 16' >> /usr/local/bin/start-redis.sh && \
    echo 'dir ${REDIS_DATA_DIR}' >> /usr/local/bin/start-redis.sh && \
    echo 'bind 0.0.0.0' >> /usr/local/bin/start-redis.sh && \
    echo 'protected-mode no' >> /usr/local/bin/start-redis.sh && \
    echo 'appendonly yes' >> /usr/local/bin/start-redis.sh && \
    echo 'appendfilename "appendonly.aof"' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo '# Add optional save intervals' >> /usr/local/bin/start-redis.sh && \
    echo 'if [ -n "$REDIS_SAVE_INTERVAL" ]; then' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "save ${REDIS_SAVE_INTERVAL}" >> /usr/local/etc/redis/redis.conf' >> /usr/local/bin/start-redis.sh && \
    echo 'else' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "save 900 1" >> /usr/local/etc/redis/redis.conf' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "save 300 10" >> /usr/local/etc/redis/redis.conf' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "save 60 10000" >> /usr/local/etc/redis/redis.conf' >> /usr/local/bin/start-redis.sh && \
    echo 'fi' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo '# Add optional memory settings' >> /usr/local/bin/start-redis.sh && \
    echo 'if [ -n "$REDIS_MAX_MEMORY" ]; then' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "maxmemory ${REDIS_MAX_MEMORY}" >> /usr/local/etc/redis/redis.conf' >> /usr/local/bin/start-redis.sh && \
    echo 'fi' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo 'if [ -n "$REDIS_MAX_MEMORY_POLICY" ]; then' >> /usr/local/bin/start-redis.sh && \
    echo '  echo "maxmemory-policy ${REDIS_MAX_MEMORY_POLICY}" >> /usr/local/etc/redis/redis.conf' >> /usr/local/bin/start-redis.sh && \
    echo 'fi' >> /usr/local/bin/start-redis.sh && \
    echo 'EOL' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo '# Start Redis Stack Server' >> /usr/local/bin/start-redis.sh && \
    echo 'exec redis-stack-server /usr/local/etc/redis/redis.conf' >> /usr/local/bin/start-redis.sh

# Make the startup script executable
RUN chmod +x /usr/local/bin/start-redis.sh

# Create a health check script
RUN echo '#!/bin/bash' > /usr/local/bin/healthcheck.sh && \
    echo 'redis-cli -p "$REDIS_PORT" -a "$REDIS_PASSWORD" ping > /dev/null 2>&1 && echo "OK" || exit 1' >> /usr/local/bin/healthcheck.sh

# Make health check script executable
RUN chmod +x /usr/local/bin/healthcheck.sh

# Health check (will use user-provided port)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Default working directory (users can override with REDIS_DATA_DIR)
WORKDIR /data

# Start Redis using our custom script
CMD ["/usr/local/bin/start-redis.sh"]