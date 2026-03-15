# Ollama + Open-WebUI with Docker Compose

This is my personal setup for running Ollama and Open-WebUI locally using Docker Compose. I use this for experimenting with local LLMs — writing, coding, general tinkering.

More details on Ollama can be found on their [GitHub](https://github.com/ollama/ollama/).

---

## Prerequisites

- Docker and Docker Compose installed on your system

---

## Setup

### 1. Create the folders

```bash
mkdir ollama openwebui
```

### 2. Ollama — `ollama/docker-compose.yml`

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama:/root/.ollama
    restart: unless-stopped
volumes:
  ollama:
```

### 3. Open-WebUI — `openwebui/docker-compose.yml`

```yaml
services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    ports:
      - "3000:8080"
    volumes:
      - open-webui:/app/backend/data
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: always
volumes:
  open-webui:
```

Your folder structure should look like this:

```
├── ollama
│   └── docker-compose.yml
└── openwebui
    └── docker-compose.yml
```

### 4. Start the containers

```bash
cd ollama && docker compose up -d
cd ../openwebui && docker compose up -d
```

### 5. Open the UI

Go to [http://localhost:3000](http://localhost:3000) and sign up on first launch.

---

## Downloading Models

Browse available models at [ollama.com/search](https://ollama.com/search). To pull one:

```bash
ollama pull gemma2:2b
```

Model sizes are listed in billions of parameters — `2b`, `7b`, `27b` etc. Bigger = smarter but slower and more memory hungry. Start small if you're unsure.

To run a model directly from the CLI:

```bash
ollama run gemma2:2b
```

---

## AMD RX 6700 XT Setup

Running on an AMD RX 6700 XT? The standard setup above won't use your GPU since the RX 6700 XT isn't officially supported by ROCm out of the box. There are dedicated guides in `/rx-6700xt/ollama/` that walk through the full setup including the GFX override needed to get it working:

- [Debian](/rx-6700xt/ollama/README.md)
- [Ubuntu](/rx-6700xt/ollama/README-ubuntu.md)
- [Fedora](/rx-6700xt/ollama/README-fedora.md)

---

## Customization

The compose files above are barebones and meant as a starting point. Check the [Ollama docs](https://github.com/ollama/ollama/blob/main/docs) and [Open-WebUI docs](https://docs.openwebui.com) for configuration options.
