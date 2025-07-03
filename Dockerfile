# Use Redis Stack latest image
FROM redis/redis-stack:latest

# Set environment variables with defaults
ENV REDIS_USERNAME=default
ENV REDIS_PASSWORD=changeme
ENV REDIS_DB=0
ENV REDIS_PORT=6379

# Install additional tools for health check
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create a custom redis.conf file
RUN echo "requirepass \${REDIS_PASSWORD}" >/usr/local/etc/redis/redis.conf &&
    echo "port \${REDIS_PORT}" >>/usr/local/etc/redis/redis.conf &&
    echo "databases \${REDIS_DB}" >>/usr/local/etc/redis/redis.conf &&
    echo "dir /data" >>/usr/local/etc/redis/redis.conf &&
    echo "save 900 1" >>/usr/local/etc/redis/redis.conf &&
    echo "save 300 10" >>/usr/local/etc/redis/redis.conf &&
    echo "save 60 10000" >>/usr/local/etc/redis/redis.conf &&
    echo "appendonly yes" >>/usr/local/etc/redis/redis.conf &&
    echo "appendfilename \"appendonly.aof\"" >>/usr/local/etc/redis/redis.conf

# Create a simple health check script
RUN echo '#!/bin/bash\nredis-cli -a $REDIS_PASSWORD ping > /dev/null 2>&1 && echo "OK" || exit 1' >/usr/local/bin/healthcheck.sh &&
    chmod +x /usr/local/bin/healthcheck.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Start Redis Stack
CMD ["redis-stack-server", "/usr/local/etc/redis/redis.conf"]
