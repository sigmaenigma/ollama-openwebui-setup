#!/bin/bash

CONTAINER_NAME="ollama-rx6700xt"
COMPOSE_DIR="$HOME/docker/ollama-rocm"
PORT="11434"

if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping Ollama to free up VRAM for gaming..."
    cd $COMPOSE_DIR && docker compose down
    echo "Ollama stopped. VRAM cleared."
else
    echo "Starting Ollama on RX 6700 XT..."
    cd $COMPOSE_DIR && docker compose up -d
    echo "----------------------------------------------------"
    echo "Ollama is running on port $PORT"
    echo "Server IP: $(hostname -I | awk '{print $1}')"
    echo "Point Open WebUI to: http://$(hostname -I | awk '{print $1}'):$PORT"
    echo "----------------------------------------------------"
    echo "Run this script again to STOP the container before gaming."
fi
