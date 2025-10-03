FROM n8nio/n8n:latest

USER root

# Install system dependencies AND build tools for Python packagess
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    bash \
    bc \
    git \
    wget \
    build-base \
    gcc \
    g++ \
    gfortran \
    musl-dev \
    python3-dev \
    openblas-dev \
    lapack-dev

# Install numpy first (other packages depend on it)
RUN pip3 install --break-system-packages numpy==1.26.2

# Install scipy and scientific packages
RUN pip3 install --break-system-packages \
    scipy==1.11.4 \
    librosa==0.10.1 \
    soundfile==0.12.1 \
    noisereduce==3.0.0

# Install media tools
RUN pip3 install --break-system-packages \
    yt-dlp \
    spotdl

# Create directories with correct permissions
RUN mkdir -p /tmp/podcast-clips && chmod 777 /tmp/podcast-clips && \
    mkdir -p /home/node/.n8n && chown -R node:node /home/node/.n8n

USER node

EXPOSE 5678

CMD ["n8n"]
