FROM n8nio/n8n:latest

USER root

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    bash \
    bc \
    git \
    wget \
    curl \
    ca-certificates \
    libsndfile \
    # If pip ever falls back to building wheels on Alpine, uncomment the next line:
    # build-base python3-dev pkgconfig \
    && true

# Install yt-dlp (official binary release)
RUN wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp \
 && chmod a+rx /usr/local/bin/yt-dlp

# Install Python packages for audio processing
RUN pip3 install --no-cache-dir --break-system-packages \
    spotdl \
    numpy \
    scipy \
    librosa \
    soundfile \
    noisereduce

# Create common dirs (note: Railway volumes mount at runtime)
RUN mkdir -p /tmp/podcast-clips /home/node/.n8n /data \
 && chmod 777 /tmp/podcast-clips \
 && chown -R node:node /home/node/.n8n /data \
 && chmod 700 /home/node/.n8n

# Quick sanity checks
RUN yt-dlp --version \
 && ffmpeg -version \
 && python3 --version \
 && spotdl --version

USER node

# n8n config
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
ENV N8N_HOST=0.0.0.0

# Point n8n's user folder at your mounted Railway volume (adjust if you mounted a different path)
ENV N8N_USER_FOLDER=/data

# Railway provides PORT at runtime; use it for N8N_PORT. Fallback to 5678 for local runs.
EXPOSE 5678
CMD ["sh","-c","N8N_PORT=${PORT:-5678} n8n"]
