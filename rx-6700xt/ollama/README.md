# Ollama on Debian with AMD RX 6700 XT (ROCm)

A guide for setting up Ollama in Docker on Debian with an AMD RX 6700 XT GPU using ROCm. The RX 6700 XT is not officially supported by AMD's ROCm stack, but can be made to work with a GFX version override.

---

## Prerequisites

- Debian (tested on Debian 12 Bookworm)
- AMD RX 6700 XT GPU
- At least 12GB VRAM + 16GB system RAM recommended
- A user with `sudo` privileges

---

## 1. Install Docker

Debian's default repositories ship an outdated version of Docker that does not include the Compose plugin. Install Docker from the official Docker repository instead.

```bash
# Remove any old Docker packages
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt update
sudo apt install ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine and Compose plugin
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Verify the installation:

```bash
docker --version
docker compose version
```

---

## 2. Set Up the Docker Named Volume

Ollama stores models in a named Docker volume. Create it before starting the container so your models persist across container rebuilds and updates.

```bash
docker volume create ollama_data
```

---

## 3. Directory Structure

Create a dedicated folder for the Ollama ROCm compose files:

```bash
mkdir -p ~/docker/ollama-rocm
cd ~/docker/ollama-rocm
```

---

## 4. docker-compose.yml

Create the compose file:

```bash
nano ~/docker/ollama-rocm/docker-compose.yml
```

```yaml
services:
  ollama-rx6700xt:
    image: ollama/ollama:rocm
    container_name: ollama-rx6700xt
    restart: unless-stopped
    devices:
      - /dev/kfd:/dev/kfd
      - /dev/dri:/dev/dri
    environment:
      - HSA_OVERRIDE_GFX_VERSION=10.3.0
      - OLLAMA_HOST=0.0.0.0:11434
    ports:
      - 11434:11434
    volumes:
      - ollama_data:/root/.ollama
    security_opt:
      - no-new-privileges:true

volumes:
  ollama_data:
    external: true
```

### Key configuration notes

- `ollama/ollama:rocm` — the official ROCm-enabled Ollama image. Do not use community or third-party images as they may become unmaintained
- `HSA_OVERRIDE_GFX_VERSION=10.3.0` — tricks ROCm into treating the RX 6700 XT (gfx1030) as a fully supported RDNA2 GPU. Without this, the GPU will not be detected
- `/dev/kfd` and `/dev/dri` — required device passthrough for GPU access inside the container
- `ollama_data:/root/.ollama` — maps the named volume to where Ollama stores models inside the container. `/root/.ollama` is the correct internal path for the official image
- `no-new-privileges:true` — security hardening that prevents privilege escalation inside the container
- Port `11434` is Ollama's default API port

---

## 5. Start Ollama

```bash
cd ~/docker/ollama-rocm
docker compose up -d
```

Verify the container is running and the GPU is detected:

```bash
docker ps
docker logs ollama-rx6700xt | grep -i "inference compute\|ROCm\|error"
docker exec ollama-rx6700xt ollama --version
```

You should see a line like:

```
inference compute id=0 library=ROCm compute=gfx1030 name=ROCm0 description="AMD Radeon Graphics" total="12.0 GiB"
```

This confirms ROCm has detected the RX 6700 XT and its 12GB of VRAM.

---

## 6. Update Script

Create an update script to keep Ollama up to date:

```bash
nano ~/docker/ollama-rocm/update_ollama.sh
```

```bash
#!/usr/bin/env bash
docker compose pull
docker compose up -d
docker image prune -f
```

Make it executable:

```bash
chmod +x ~/docker/ollama-rocm/update_ollama.sh
```

Run it any time you want to update to the latest ROCm image:

```bash
./update_ollama.sh
```

---

## 7. Connecting OpenWebUI

If you are running OpenWebUI on a separate server, point it to your Ollama instance at:

```
http://<your-server-ip>:11434
```

This is configured in OpenWebUI under **Settings → Connections**.

---

## 8. Model Size Guidelines

With 12GB VRAM and ~32GB system RAM, here is a rough guide for what will run:

| Model Size | Behaviour |
|---|---|
| Up to ~12GB | Runs fully in VRAM — fast |
| 12GB–36GB | Split between VRAM and RAM — slower but usable |
| Over 36GB | Will likely fail or be very slow |

Ollama handles VRAM/RAM splitting automatically. Quantized models (Q4, Q5) are smaller and will fit more comfortably in VRAM than full precision versions.

---

## 9. Troubleshooting

**`docker: 'compose' is not a docker command`**
Your Docker is from Debian's default repos and is outdated. Follow Step 1 to install from Docker's official repo.

**`pull access denied` when pulling an image**
The image no longer exists or has been made private. Always use the official `ollama/ollama:rocm` image.

**`unknown model architecture`**
Your Ollama version is too old to support the model you are trying to load. Run `./update_ollama.sh` to get the latest image.

**GPU not detected / model running on CPU only**
Check that `HSA_OVERRIDE_GFX_VERSION=10.3.0` is set in your compose file and that `/dev/kfd` and `/dev/dri` are passed through correctly.

**Models not persisting after container rebuild**
Make sure `ollama_data` is a named external volume created with `docker volume create ollama_data` and that `external: true` is set in the compose file.
