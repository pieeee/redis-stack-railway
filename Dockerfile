# Use Redis Stack latest image
FROM redis/redis-stack:latest

# Set environment variables with defaults
ENV REDIS_USERNAME=default
ENV REDIS_PASSWORD=changeme
ENV REDIS_DB=0
ENV REDIS_PORT=6379

# Install additional tools for health check
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create data directory
RUN mkdir -p /data

# Create a startup script that handles environment variable substitution
RUN echo '#!/bin/bash' > /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo '# Create redis.conf with environment variable substitution' >> /usr/local/bin/start-redis.sh && \
    echo 'cat > /usr/local/etc/redis/redis.conf << EOL' >> /usr/local/bin/start-redis.sh && \
    echo 'requirepass ${REDIS_PASSWORD}' >> /usr/local/bin/start-redis.sh && \
    echo 'port ${REDIS_PORT}' >> /usr/local/bin/start-redis.sh && \
    echo 'databases 16' >> /usr/local/bin/start-redis.sh && \
    echo 'dir /data' >> /usr/local/bin/start-redis.sh && \
    echo 'save 900 1' >> /usr/local/bin/start-redis.sh && \
    echo 'save 300 10' >> /usr/local/bin/start-redis.sh && \
    echo 'save 60 10000' >> /usr/local/bin/start-redis.sh && \
    echo 'appendonly yes' >> /usr/local/bin/start-redis.sh && \
    echo 'appendfilename "appendonly.aof"' >> /usr/local/bin/start-redis.sh && \
    echo 'bind 0.0.0.0' >> /usr/local/bin/start-redis.sh && \
    echo 'protected-mode no' >> /usr/local/bin/start-redis.sh && \
    echo 'EOL' >> /usr/local/bin/start-redis.sh && \
    echo '' >> /usr/local/bin/start-redis.sh && \
    echo '# Start Redis Stack Server' >> /usr/local/bin/start-redis.sh && \
    echo 'exec redis-stack-server /usr/local/etc/redis/redis.conf' >> /usr/local/bin/start-redis.sh

# Make the startup script executable
RUN chmod +x /usr/local/bin/start-redis.sh

# Create a health check script
RUN echo '#!/bin/bash' > /usr/local/bin/healthcheck.sh && \
    echo 'redis-cli -a "$REDIS_PASSWORD" ping > /dev/null 2>&1 && echo "OK" || exit 1' >> /usr/local/bin/healthcheck.sh

# Make health check script executable
RUN chmod +x /usr/local/bin/healthcheck.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Expose the Redis port
EXPOSE ${REDIS_PORT}

# Set working directory
WORKDIR /data

# Start Redis using our custom script
CMD ["/usr/local/bin/start-redis.sh"]