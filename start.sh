#!/bin/bash

# Define local directories for output
local_debug_dir="$HOME/.debug"
local_data_dir="./perf-data"

# Name of the file to be copied
file_name="perf.data.old"

# Ensure the local directories exist
mkdir -p "$local_debug_dir"
mkdir -p "$local_data_dir"

# Start up docker-compose services
echo "Starting Docker Compose services..."
docker compose up -d > /dev/null 2>&1

# Allow services to run for 70 seconds
echo "Waiting for 200 seconds..."
sleep 200s

# Copy /root/.debug from topos-node-1 container to local ~/.debug directory
echo "Copying /root/.debug from topos-node-1 to local ~/.debug directory..."
docker cp topos-node-1:/root/.debug "$local_debug_dir"

# Copy perf.data from the perf_topos-data volume to the local data directory
echo "Copying perf.data from perf_topos-data volume to local $local_data_dir..."
docker run --rm -v perf_topos-data:/data -v "$local_data_dir":/backup ubuntu \
    bash -c "cp -ar /data/$file_name /backup/"

# Change ownership of the copied files to the local user
echo "Changing ownership of the copied files to the local user..."
sudo chown -R $(id -u):$(id -g) "$local_debug_dir"
sudo chown -R $(id -u):$(id -g) "$local_data_dir/$file_name"

# Stop and remove docker-compose services
echo "Stopping Docker Compose services..."
docker compose down -v > /dev/null 2>&1

echo "Operations completed."

