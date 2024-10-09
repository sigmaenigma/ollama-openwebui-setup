# Installing Ollama and Open-WebUI with Docker Compose

This guide will walk you through deploying Ollama and Open-WebUI using Docker Compose. Whether you’re writing poetry, generating stories, or experimenting with creative content, this setup will help you get started with a locally running AI!! 

## Prerequisites

Ensure that you have the following prerequisites:

- Docker and Docker Compose installed on your system.

## Installation Steps

### 1. Install Ollama and Open-WebUI

You can install Ollama directly using this [link](https://ollama.com/download) for Windows, MacOS, or Linux.

For OpenWebUI, follow the [official documentation](https://docs.openwebui.com/getting-started/).

### 2. Docker Compose Configuration

Create a `docker-compose.yml` file with the following content:

```yaml
services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    restart: always
    ports:
      - "3000:8080"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    volumes:
      - open-webui-local:/app/backend/data

  ollama:
    image: ollama/ollama:0.1.34
    ports:
      - "11434:11434"
    volumes:
      - ollama-local:/root/.ollama

volumes:
  ollama-local:
    external: true
  open-webui-local:
    external: true
```

Replace the placeholder values with your specific configurations.

### 3. Create Docker Volumes

Run the following commands to create the necessary Docker volumes:

```sh
docker volume create ollama-local
docker volume create open-webui-local
```

### 4. Deploy the Containers

Deploy both Ollama and Open-WebUI using Docker Compose:

```sh
docker-compose up -d
```

### 5. Access Open-WebUI

Once the containers are up and running, you can access Open-WebUI in your web browser using the specified port (e.g., [http://localhost:3000](http://localhost:3000)). If you access Open-WebUI for the first time, sign up to get started.

## Customization

Feel free to customize the installation according to your server’s specifications and preferences. If you encounter any issues, refer to the official Docker and NVIDIA documentation for troubleshooting tips.
