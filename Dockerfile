# Glibc-based to avoid building llvmlite/numba from source
FROM node:20-bookworm-slim

USER root

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    ffmpeg \
    bash bc git wget curl ca-certificates \
    libsndfile1 \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Install n8n (officially supported via npm)
RUN npm install -g n8n

# yt-dlp (official release binary)
RUN wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -O /usr/local/bin/yt-dlp \
 && chmod a+rx /usr/local/bin/yt-dlp

# --- Python virtual environment to satisfy PEP 668 ---
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# Python packages for audio processing (install into the venv)
RUN pip install --no-cache-dir \
    spotdl \
    numpy \
    scipy \
    librosa \
    soundfile \
    noisereduce

# Create dirs (Railway volumes mount at runtime)
RUN mkdir -p /tmp/podcast-clips /home/node/.n8n /data \
 && chmod 777 /tmp/podcast-clips \
 && chown -R node:node /home/node/.n8n /data \
 && chmod 700 /home/node/.n8n

# Quick sanity checks
RUN yt-dlp --version \
 && ffmpeg -version \
 && python3 --version \
 && /opt/venv/bin/python --version \
 && /opt/venv/bin/pip --version \
 && n8n --version

# Drop privileges for runtime
USER node

# n8n config (point this to your Railway volume mount)
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
ENV N8N_HOST=0.0.0.0
ENV N8N_USER_FOLDER=/data

# Railway provides $PORT at runtime; fallback to 5678 locally
EXPOSE 5678
CMD ["sh","-c","N8N_PORT=${PORT:-5678} n8n"]
