#!/bin/bash

# Check if profiling is enabled
if [ $PROFILING == true ]; then   
    echo "Starting perf monitoring for 5 minutes..."
    perf record -F 99 --call-graph dwarf -o /data/perf.data ./target/release/topos "$@" &
    perf_pid=$!

    # Sleep for 180 seconds or the duration you need for the profiling
    sleep 180

    # After the sleep, send SIGINT to perf to gracefully end the recording
    echo "Stopping perf recording..."
    kill -SIGINT $perf_pid
    wait $perf_pid
else
    # Execute the application normally if profiling is not enabled
    exec ./target/release/topos "$@"
fi

