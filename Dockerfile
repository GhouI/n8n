# Debian-based, glibc — avoids compiling llvmlite/numba
FROM node:20-bookworm-slim

# Install system deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip \
    ffmpeg \
    bash bc git wget curl ca-certificates \
    libsndfile1 \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Install n8n globally (officially supported npm install)
RUN npm install -g n8n

# yt-dlp (official release binary)
RUN wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -O /usr/local/bin/yt-dlp \
 && chmod a+rx /usr/local/bin/yt-dlp

# Python packages
RUN pip3 install --no-cache-dir \
    spotdl \
    numpy \
    scipy \
    librosa \
    soundfile \
    noisereduce

# Create dirs & permissions (Railway volume mounts at runtime)
RUN mkdir -p /tmp/podcast-clips /home/node/.n8n /data \
 && chmod 777 /tmp/podcast-clips \
 && chown -R node:node /home/node/.n8n /data \
 && chmod 700 /home/node/.n8n

# Quick sanity checks
RUN yt-dlp --version && ffmpeg -version && python3 --version && n8n --version

USER node

# n8n config (Railway: mount your volume at /data or change this)
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
ENV N8N_HOST=0.0.0.0
ENV N8N_USER_FOLDER=/data

# Railway provides $PORT at runtime; fall back to 5678 locally
EXPOSE 5678
CMD ["sh","-c","N8N_PORT=${PORT:-5678} n8n"]
