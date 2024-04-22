# Local environment to take performance measurements of validators 

### Requirements

* The host system has to match the one from the Dockerfile. In this example, it is `Ubuntu 22.04`.
* The host system has to have `perf` installed.
* `docker` and `docker-compose` have to be installed.

### HowTo

The script `perf.sh` will start a docker compose environment with 4 validators and 1 spammer. The arguments of the spammer can be adjusted in the compose file `spammer.yml`. 

* `git clone git@github.com:topos-protocol/perf-environment.git`
* `cd perf-environment`
* `./perf.sh`

### Evaluate the data

The script is saving the `perf.data` into the folder `perf_outputs` inside the project directory. From there, you can digest the data.

One example: https://www.brendangregg.com/FlameGraphs/cpuflamegraphs.html

For this, you have to have the [`FlameGraph` repository](https://github.com/brendangregg/FlameGraph) locally and use the `stackcollapse-perf.pl` and `flamegraph.pl` script included.

```bash
perf script | ./stackcollapse-perf.pl > out.perf-folded
./flamegraph.pl out.perf-folded > perf.svg
firefox perf.svg  # or chrome, etc.

```

## License

This project is released under the terms of the MIT license.
