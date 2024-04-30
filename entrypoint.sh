#!/bin/bash

# Define the path to the perf.data file
perf_data_path="/data/perf.data"

# Check if profiling is enabled and perf.data does not already exist
if [[ $PROFILING == true && ! -f $perf_data_path ]]; then   
    echo "Starting perf monitoring for 5 minutes..."
    perf record -F 99 --call-graph dwarf -o $perf_data_path ./target/release/topos "$@" &
    perf_pid=$!

    # Sleep for 180 seconds or the duration you need for the profiling
    sleep 180

    # After the sleep, send SIGINT to perf to gracefully end the recording
    echo "Stopping perf recording..."
    kill -SIGINT $perf_pid
    wait $perf_pid
else
    # Execute the application normally if profiling is not enabled or perf.data already exists
    echo "Executing application normally..."
    exec ./target/release/topos "$@"
fi

