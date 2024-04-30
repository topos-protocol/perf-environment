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

The `start.sh` is starting `docker compose up`, which in turn builds the `Dockerfile`, which downloads either the latest `main` or a `PR` from the `topos` repository, and builds it via debugging `RUSTFLAGS`. After building the container, it starts 4 `topos` nodes, and one `spammer`. The `topos` nodes are being started via the `entrypoint.sh` script, which starts the `perf` command for `topos-node-1`. After 3 minutes, we create a Profiler Report out of the recorded data, and save it to the local `perf-outputs` folder. This `data.perf` can be viewed via Firefox Profiler.


## License

This project is released under the terms of the MIT license.
