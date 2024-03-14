<h1 align="center">sysbench</h1>
<p align="center">A scriptable multi-threaded benchmark tool based on LuaJIT.</p>

## Table of Contents

- [About](#about)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [References](#references)

## About <a name="about"></a>

sysbench is a scriptable multi-threaded benchmark tool based on
LuaJIT. It is most frequently used for database benchmarks, but can also
be used to create arbitrarily complex workloads that do not involve a
database server.

sysbench comes with the following bundled benchmarks:

- `oltp_*.lua`: a collection of OLTP-like database benchmarks
- `fileio`: a filesystem-level benchmark
- `cpu`: a simple CPU benchmark
- `memory`: a memory access benchmark
- `threads`: a thread-based scheduler benchmark
- `mutex`: a POSIX mutex benchmark

## Requirements <a name="requirements"></a>

You must have docker installed in your machine to run the project. If you don't have docker installed, please follow the instructions at <https://docs.docker.com/desktop/> to install it.

## Installation <a name="installation"></a>

1. Clone this repository and enter the directory

```bash
git clone https://github.com/CNuvem23/sysbench.git && \
cd sysbench
```

2. Run the Docker image using the commands described in the [Usage](#usage) section.

## Usage <a name="usage"></a>

``` bash
Usage: ./run_docker_benchmark.sh <tag:alpine|debian> <cmd:build|pull|local> <mode:docker|dind> <docker_stats:yes|no> <n_times_exec> <other_sysbench_args>
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
  other_benchmark_args: other optional sysbench arguments
```

These are some parameters that can be used to run sysbench:

``` bash
Usage: sysbench [options]... [testname] [command] 

- *options* is a list of zero or more command line options starting with
 `'--'`. As with commands, the `sysbench testname help` command
 should be used to describe available options provided by a
 particular test.

- *testname* is an optional name of a built-in test (e.g. `fileio`,
  `memory`, `cpu`, etc.), or a name of one of the bundled Lua scripts
  (e.g. `oltp_read_only`), or a *path* to a custom Lua script. If no
  test name is specified on the command line (and thus, there is no
  *command* too, as in that case it would be parsed as a *testname*), or
  the test name is a dash ("`-`"), then sysbench expects a Lua script to
  execute on its standard input.

- *command* is an optional argument that will be passed by sysbench to
  the built-in test or script specified with *testname*. *command*
  defines the *action* that must be performed by the test. The list of
  available commands depends on a particular test. Some tests also
  implement their own custom commands.

```

## References <a name="references"></a>

- [sysbench](https://github.com/akopytov/sysbench)
