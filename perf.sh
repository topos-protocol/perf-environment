#!/bin/bash

# Start the docker-compose services
docker compose up -d

# Wait for the application to start properly
echo "Waiting for the network to start..."
sleep 30 

# Find the PID of the running topos application
PID=$(docker exec topos-node-1 pgrep topos)

# Start perf monitoring
echo "Starting perf monitoring..."
docker exec -it topos-node-1 perf record -p $PID -o /data/perf.data sleep 300

# Generate a report
echo "Generating perf report..."
docker exec -it topos-node-1 perf report -i /data/perf.data > ./perf_outputs/perf.report

# Stop the container
docker-compose down

echo "Monitoring complete. Data saved to ./perf_outputs/perf.report"

