FROM node:20-bookworm-slim

# ---- System deps ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    ffmpeg \
    bash bc git wget curl ca-certificates \
    libsndfile1 \
    build-essential \
    gosu \
 && rm -rf /var/lib/apt/lists/*

# ---- n8n ----
RUN npm install -g n8n

# ---- yt-dlp (official binary) ----
RUN wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp \
 && chmod a+rx /usr/local/bin/yt-dlp

# ---- Python venv (PEP 668 friendly) ----
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

# ---- Python packages (in venv) ----
RUN pip install --no-cache-dir \
    spotdl \
    numpy \
    scipy \
    librosa \
    soundfile \
    noisereduce

# ---- Dirs (your volume mounts at /home/node/.n8n) ----
RUN mkdir -p /tmp/podcast-clips /home/node/.n8n \
 && chmod 777 /tmp/podcast-clips \
 && chown -R node:node /home/node/.n8n

# ---- Entrypoint: ensure mount is writable, then drop to `node` and run n8n ----
RUN printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -euo pipefail' \
  'mkdir -p /home/node/.n8n || true' \
  'chown -R node:node /home/node/.n8n || true' \
  'export N8N_HOST="${N8N_HOST:-0.0.0.0}"' \
  'export N8N_USER_FOLDER="${N8N_USER_FOLDER:-/home/node/.n8n}"' \
  'export N8N_PORT="${N8N_PORT:-${PORT:-5678}}"' \
  'export N8N_LOG_LEVEL="${N8N_LOG_LEVEL:-debug}"' \
  'export NODE_OPTIONS="${NODE_OPTIONS:---max-old-space-size=512}"' \
  'echo "[entrypoint] N8N_HOST=$N8N_HOST N8N_PORT=$N8N_PORT N8N_USER_FOLDER=$N8N_USER_FOLDER"' \
  'echo "[entrypoint] NODE_OPTIONS=$NODE_OPTIONS N8N_LOG_LEVEL=$N8N_LOG_LEVEL"' \
  'yt-dlp --version || true' \
  'ffmpeg -version | head -n1 || true' \
  'python3 --version || true' \
  'n8n --version || true' \
  'exec gosu node:node n8n' \
  > /usr/local/bin/docker-entrypoint.sh \
 && chmod +x /usr/local/bin/docker-entrypoint.sh

# ---- Runtime envs (override in Railway if needed) ----
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
ENV N8N_HOST=0.0.0.0
ENV N8N_USER_FOLDER=/home/node/.n8n

EXPOSE 5678
CMD ["/usr/local/bin/docker-entrypoint.sh"]
