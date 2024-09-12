# Dockerfile

# Use an official lightweight base image
FROM alpine:latest

# Install necessary packages
RUN apk --no-cache add bash curl bc procps coreutils

# Set working directory
WORKDIR /app

# Copy the monitor_resources.sh script and .env file into the container
COPY monitor_resources.sh /app/monitor_resources.sh
COPY .env /app/.env

# Make the script executable
RUN chmod +x /app/monitor_resources.sh

# Run the monitoring script
CMD ["./monitor_resources.sh"]
