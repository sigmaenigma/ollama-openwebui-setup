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

Create two folders. Name one `ollama` and name the other `openwebui`. 

### 3. In the `ollama` folder, create a file named  `docker-compose.yml` file with the following content:

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
### 4. In the `openwebui` folder, create a file named  `docker-compose.yml` file with the following content:

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

You will have two folders with two different `docker-compose.yaml` files:
```bash
├── ollama
│   ├── docker-compose.yaml
├── openwebui
│   ├── docker-compose.yaml
```

### 5. Deploy the Containers

Deploy both the Ollama `/ollama` and Open-WebUI `/openwebui` using Docker Compose:

```bash
cd ollama
docker-compose up -d
cd ..
cd openwebui
docker-compose up -d
```

### 6. Access Open-WebUI

Once the containers are up and running, you can access Open-WebUI in your web browser using the specified port (e.g., [http://localhost:3000](http://localhost:3000)). If you access Open-WebUI for the first time, sign up to get started.

## Downloading Additional Models

To enhance your AI capabilities, you can download various models that focus on different features, such as code generation, storytelling, and more. Here are the steps to download and use additional models with Ollama:

### 1. Explore Available Models

Visit the [Ollama Models](https://ollama.com/search) page to explore the available models. You can find models tailored for different tasks, such as code generation, natural language processing, and more.

### 2. Download a Model

Use the Ollama command-line interface (CLI) to download the desired model. For example, to download a model named `gemma2:2b`, use the following command:

```bash
ollama pull gemma2:2b
```

Note that for some models, you can actually specify the size (e.g. 2b, 7b, 27b means BILLIONS of parameters!)

### 3. Configure the Model

After downloading the model, you may need to configure it by creating a model file that specifies the model's parameters, system prompt, and template. Refer to the [Ollama documentation](https://ollama.com/docs) for detailed instructions on configuring models.

### 4. Run the Model

Once the model is configured, you can run it using the Ollama CLI or integrate it into your applications using the Ollama API. For example, to run the `gemma2:2b` model, use the following command:

```bash
ollama run gemma2:2b
```

## Customization

Feel free to customize the installation according to your server’s specifications and preferences. If you encounter any issues, refer to the official Docker and NVIDIA documentation for troubleshooting tips.
