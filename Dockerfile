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
RUN cat > /usr/local/bin/start-redis.sh << 'EOF'
#!/bin/bash

# Create redis.conf with environment variable substitution
cat > /usr/local/etc/redis/redis.conf << EOL
requirepass ${REDIS_PASSWORD}
port ${REDIS_PORT}
databases 16
dir /data
save 900 1
save 300 10
save 60 10000
appendonly yes
appendfilename "appendonly.aof"
bind 0.0.0.0
protected-mode no
EOL

# Start Redis Stack Server
exec redis-stack-server /usr/local/etc/redis/redis.conf
EOF

# Make the startup script executable
RUN chmod +x /usr/local/bin/start-redis.sh

# Create a health check script
RUN cat > /usr/local/bin/healthcheck.sh << 'EOF'
#!/bin/bash
redis-cli -a "$REDIS_PASSWORD" ping > /dev/null 2>&1 && echo "OK" || exit 1
EOF

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