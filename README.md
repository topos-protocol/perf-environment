# Local environment to take performance measurements of validators 

### Requirements

* The host system has to match the one from the Dockerfile. In this example, it is `Ubuntu 22.04`.
* The host system has to have `perf` installed.
* `docker` and `docker-compose` have to be installed.

### HowTo

We start a local docker compose environment with 4 validators and 1 spammer. The arguments of the spammer can be adjusted in the compose file `spammer.yml`. 

* `git clone git@github.com:topos-protocol/perf-environment.git`
* `cd perf-environment`
* `./start.sh`


### Behind the scenes

The `entrypoint.sh` will start the `perf` command for `topos-node-1`, and stop after 3 minutes of recording the data. Afterwards, the script is copying the created `perf.data` file and the debug symbols to the local hard drive: 

* `docker cp topos-node-1:/root/.debug ~/`
* `docker cp topos-node-1:/data/perf.data.old ./perf-data`


**It could be that the docker container is restarting due to resource issues. Then insted of copying `perf.data`, we need to copy `.perf.data.old`**

The issue is that sometimes the `perf` command will crash the docker container when finishing the report, resulting in a restart, and a `perf.data.old` file. Therefore we almost expect this to happen and copy the `.old` file to the local folder structure. This part of the setup is flaky and you might want to get into the container and observe:

* `docker exec -ti topos-node-1 /bin/bash`
* `cd /data`


### Create a profile for Firefox Profiler

* `perf script > data.perf` 


### Evaluate the data

The script is saving the `perf.data` into the folder `perf-data` inside the project directory. From there, you can digest the data.

One example: https://www.brendangregg.com/FlameGraphs/cpuflamegraphs.html

For this, you have to have the [`FlameGraph` repository](https://github.com/brendangregg/FlameGraph) locally and use the `stackcollapse-perf.pl` and `flamegraph.pl` script included.

```bash
perf script | ./stackcollapse-perf.pl > out.perf-folded
./flamegraph.pl out.perf-folded > perf.svg
firefox perf.svg  # or chrome, etc.

```

## License

This project is released under the terms of the MIT license.
