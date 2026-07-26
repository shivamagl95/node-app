# Use a minimal, secure base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy only package files first for better layer caching
COPY package.json ./

# Copy application source
COPY server.js ./

# Create a non-root user and group, and give ownership of the app dir
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 3000

ENV PORT=3000
ENV NODE_ENV=production

CMD ["node", "server.js"]