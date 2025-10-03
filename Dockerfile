FROM n8nio/n8n:latest

USER root

# Install only essential dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    bash \
    bc \
    git \
    wget

# Install only media download tools (no audio processing libraries)
RUN pip3 install --break-system-packages \
    yt-dlp \
    spotdl

# Create directories with correct permissions
RUN mkdir -p /tmp/podcast-clips && chmod 777 /tmp/podcast-clips && \
    mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node

EXPOSE 5678

CMD ["n8n"]
