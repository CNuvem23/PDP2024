<h1 align="center">stress</h1>
<p align="center">Tool that imposes a configurable amount of CPU, memory, I/O, or disk stress on a POSIX-compliant operating system and reports any errors it detects.</p>

## Table of Contents

- [About](#about)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [References](#references)

## About <a name="about"></a>

**Please check the stress repository at <https://github.com/resurrecting-open-source-projects/stress> for more information.**

> stress is a tool that imposes a configurable amount of CPU, memory, I/O, or disk stress on a POSIX-compliant operating system and reports any errors it detects.
> stress is not a benchmark. It is a tool used by system administrators to evaluate how well their systems will scale, by kernel programmers to evaluate perceived performance characteristics, and by systems programmers to expose the classes of bugs which only or more frequently manifest themselves when the system is under heavy load.

This project was created to run a benchmark of the stress tool using Docker and Docker-in-Docker(dind).

## Requirements <a name="requirements"></a>

You must have docker installed in your machine to run the project. If you don't have docker installed, please follow the instructions at <https://docs.docker.com/desktop/> to install it.

## Installation <a name="installation"></a>

1. Clone this repository and enter the directory

```bash
git clone https://github.com/CNuvem23/stress.git && \
cd stress
```

2. Run the Docker image using the commands described in the [Usage](#usage) section.

## Usage <a name="usage"></a>

``` bash
Usage: ./run_docker_benchmark.sh <tag:alpine|debian> <cmd:build|pull|local> <mode:docker|dind> <docker_stats:yes|no> <n_times_exec> <other_benchmark_args>
  tag: alpine|debian
  cmd: 
    build = build image first: docker build -f Dockerfile.TAG
    pull  = get image from Docker Hub: docker pull cnuvem23/stress:tag
    local = just run local image: docker run -it cnuvem23/stress:tag
  mode: 
    docker = docker only
    dind   = docker in docker
  docker_stats: 
    yes = collect docker stats
    no  = do NOT collect docker stats
  n_times_exec: (int) number of times to execute the benchmark
  other_benchmark_args: other optional benchmark-specific arguments
```

These are some parameters that can be used to run stress:

``` bash
Usage: stress [OPTION [ARG]] ...
 -?, --help         show this help statement
     --version      show version statement
 -v, --verbose      be verbose
 -q, --quiet        be quiet
 -n, --dry-run      show what would have been done
 -t, --timeout N    timeout after N seconds
     --backoff N    wait factor of N microseconds before work starts
 -c, --cpu N        spawn N workers spinning on sqrt()
 -i, --io N         spawn N workers spinning on sync()
 -m, --vm N         spawn N workers spinning on malloc()/free()
     --vm-bytes B   malloc B bytes per vm worker (default is 256MB)
     --vm-stride B  touch a byte every B bytes (default is 4096)
     --vm-hang N    sleep N secs before free (default none, 0 is inf)
     --vm-keep      redirty memory instead of freeing and reallocating
 -d, --hdd N        spawn N workers spinning on write()/unlink()
     --hdd-bytes B  write B bytes per hdd worker (default is 1GB)

Example: stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 10s

Note: Numbers may be suffixed with s,m,h,d,y (time) or B,K,M,G (size).
```

## Examples <a name="examples"></a>

As described in stress man page, it is recommended to run the tests with a number of workers equal to the number of fisical cores in the machine. But in the tests wore chosen to use only one worker for each test to make the tests more accurate trying to avoid the interference of other processes in the results, like with a change of context during the execution of the tests.

The "ALL" test was performed to check if the results of the tests with only one worker had a similar behavior with the results of the tests with 4 workers.

The load of the tests wore set to defult values, following the experience of stress developers.

The tests were performed using the following parameters:

1. CPU test
    - CPU: 1 worker
    - IO: 0 worker
    - VM: 0 worker
    - HDD: 0 worker
    - Timeout: 10 seconds

1. I/O test

    - CPU: 0 worker
    - IO: 1 worker
    - VM: 0 worker
    - HDD: 0 worker
    - Timeout: 10 seconds

1. VM test

    - CPU: 0 worker
    - IO: 0 worker
    - VM: 1 worker, malloc 256MB, touch a byte every 4096 bytes
    - HDD: 0 worker
    - Timeout: 10 seconds

1. HDD test

    - CPU: 0 worker
    - IO: 0 worker
    - VM: 0 worker
    - HDD: 1 worker, write 1GB
    - Timeout: 10 seconds

1. ALL test

    - CPU: 1 worker
    - IO: 1 worker
    - VM: 1 worker, malloc 256MB, touch a byte every 4096 bytes
    - HDD: 1 worker, write 1GB
    - Timeout: 10 seconds

## Testing Environment

1. The tool was tested in a machine with the following specifications:

- Linux Mint 21.2 Cinnamon
- Kernel 5.15.0-84-generic
- Ryzen 7 3700X 8-Core
- 16GB RAM DDR4 3600MHz
- 1TB SSD NVMe

Docker version 24.0.5

1. Macbook Pro 2021 with the following specifications:

- macOS Sonoma 14.0
- Apple M1 Pro
- 16GB RAM
- 512GB SSD

Docker version 24.0.5

## References <a name="references"></a>

- [stress](https://github.com/resurrecting-open-source-projects/stress)
