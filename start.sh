#!/bin/bash

# Define local directory for output and the name of the output file
local_project_dir="./perf-data"  # Update this path to your actual project directory
output_file="data.perf"

# Ensure the local directory exists
mkdir -p "$local_project_dir"

# Start up docker-compose services and suppress output
echo "Docker Compose starting..."
docker compose up -d > /dev/null 2>&1

# Allow services to run for 70 seconds
echo "Waiting for 200 seconds..."
sleep 200s

# Navigate to /data in topos-node-1 and run perf script
echo "Running perf script inside topos-node-1..."
docker exec topos-node-1 bash -c "cd /data && perf script -i perf.data.old > $output_file"

# Copy data.perf from topos-node-1 to local project folder
echo "Copying $output_file from topos-node-1 to local project folder..."
docker cp topos-node-1:/data/$output_file "$local_project_dir/$output_file"

# Stop and remove docker-compose services and suppress output
echo "Docker Compose stopping..."
docker compose down > /dev/null 2>&1

echo "Operations completed."

