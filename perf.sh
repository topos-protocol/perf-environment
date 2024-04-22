#!/bin/bash

# Start the docker-compose services
docker compose up -d 

# Find the PID of the running topos application
PID=$(docker exec topos-node-1 pgrep topos)

# Start perf monitoring
echo "Starting perf monitoring..."
docker exec -it topos-node-1 perf record -F 99 --call-graph dwarf -g -p $PID -o /data/perf.data sleep 300

# Generate a report
echo "Saving perf.data to local project folder..."
docker cp topos-node-1:/data/perf.data ./perf_outputs/perf.data

# Stop the container
docker compose down -v 

echo "Monitoring complete. Data saved to ./perf_outputs/perf.data"

