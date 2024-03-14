<h1 align="center">iperf</h1>
<p align="center">Tool for TCP and UDP Network Performance Testing</p>


## Table of Contents
- [About](#about)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [References](#references)

## About <a name="about"></a>

iperf is an open-source tool that allows us to measure performance in the field of computer networks based on IP, such as bandwidth testing, latency, packet loss, among others. iperf operates on a client-server model, where one device acts as the server that listens for connections, and another as the client that connects to perform performance tests.

This project aims to automate the execution of iperf in a Docker container, allowing the user to perform performance tests in a simple and fast way.

## Requirements <a name="requirements"></a>

To run this experiment by an automatic way, please install [Docker](https://www.docker.com/).

### Manual install requirements (without Docker)

The iperf app is cross-platform and can be installed on various operating systems, including Windows, Linux, Mac OS X, FreeBSD, NetBSD, OpenBSD, Solaris, Android, iOS, among others. This software is very small in terms of disk size, taking up less than 1MB.

## Installation <a name="installation"></a>

This project has an automated way to run iperf using Docker. No installation is required, just follow the [usage](#usage) instructions.

To manually iperf, simply visit the [official tool website](https://iperf.fr/iperf-download.php) and download the version compatible with your operating system.

## Usage <a name="usage"></a>

To run this experiment by an automatic way, please run the following command:

```bash
# Usage: ./run_docker_benchmark.sh <tag:alpine|debian> <cmd:build|pull|local> <mode:docker|dind> <n_times> <additional_client_parameters>
./run_docker_benchmark.sh alpine pull dind 2 -e -d
```

This command will execute both iperf server and client.

By default, the given parameters are going to be bypassed to the iperf client.

The following is a summary of the parameters that can be used with iperf:

```
Usage: iperf [-s|-c host] [options]
       iperf [-h|--help] [-v|--version]

Client/Server:
  -b, --bandwidth #[kmgKMG | pps]  bandwidth to read/send at in bits/sec or packets/sec
  -e, --enhanced    use enhanced reporting giving more tcp/udp and traffic information
  -f, --format    [kmgKMG]   format to report: Kbits, Mbits, KBytes, MBytes
      --hide-ips           hide ip addresses and host names within outputs
  -i, --interval  #        seconds between periodic bandwidth reports
  -l, --len       #[kmKM]    length of buffer in bytes to read or write (Defaults: TCP=128K, v4 UDP=1470, v6 UDP=1450)
  -m, --print_mss          print TCP maximum segment size (MTU - TCP/IP header)
  -o, --output    <filename> output the report or error message to this specified file
  -p, --port      #        client/server port to listen/send on and to connect
      --permit-key         permit key to be used to verify client and server (TCP only)
      --sum-only           output sum only reports
  -u, --udp                use UDP rather than TCP
  -w, --window    #[KM]    TCP window size (socket buffer size)
  -z, --realtime           request realtime scheduler
  -B, --bind <host>[:<port>][%<dev>] bind to <host>, ip addr (including multicast address) and optional port and device
  -C, --compatibility      for use with older versions does not sent extra msgs
  -M, --mss       #        set TCP maximum segment size (MTU - 40 bytes)
  -N, --nodelay            set TCP no delay, disabling Nagle's Algorithm
  -S, --tos       #        set the socket's IP_TOS (byte) field
  -Z, --tcp-congestion <algo>  set TCP congestion control algorithm (Linux only)

Server specific:
  -p, --port      #[-#]    server port(s) to listen on/connect to
  -s, --server             run in server mode
  -1, --singleclient       run one server at a time
      --histograms         enable latency histograms
      --permit-key-timeout set the timeout for a permit key in seconds
      --tcp-rx-window-clamp set the TCP receive window clamp size in bytes
      --tap-dev   #[<dev>] use TAP device to receive at L2 layer
  -t, --time      #        time in seconds to listen for new connections as well as to receive traffic (default not set)
      --udp-histogram #,#  enable UDP latency histogram(s) with bin width and count, e.g. 1,1000=1(ms),1000(bins)
  -B, --bind <ip>[%<dev>]  bind to multicast address and optional device
  -U, --single_udp         run in single threaded UDP mode
      --sum-dstip          sum traffic threads based upon destination ip address (default is src ip)
  -D, --daemon             run the server as a daemon
  -V, --ipv6_domain        Enable IPv6 reception by setting the domain and socket to AF_INET6 (Can receive on both IPv4 and IPv6)

Client specific:
  -c, --client    <host>   run in client mode, connecting to <host>
      --connect-only       run a connect only test
      --connect-retries #  number of times to retry tcp connect
  -d, --dualtest           Do a bidirectional test simultaneously (multiple sockets)
      --fq-rate #[kmgKMG]  bandwidth to socket pacing
      --full-duplex        run full duplex test using same socket
      --ipg                set the the interpacket gap (milliseconds) for packets within an isochronous frame
      --isochronous <frames-per-second>:<mean>,<stddev> send traffic in bursts (frames - emulate video traffic)
      --incr-dstip         Increment the destination ip with parallel (-P) traffic threads
      --incr-dstport       Increment the destination port with parallel (-P) traffic threads
      --incr-srcip         Increment the source ip with parallel (-P) traffic threads
      --incr-srcport       Increment the source port with parallel (-P) traffic threads
      --local-only         Set don't route on socket
      --near-congestion=[w] Use a weighted write delay per the sampled TCP RTT (experimental)
      --no-connect-sync    No sychronization after connect when -P or parallel traffic threads
      --no-udp-fin         No final server to client stats at end of UDP test
  -n, --num       #[kmgKMG]    number of bytes to transmit (instead of -t)
  -r, --tradeoff           Do a fullduplexectional test individually
      --tcp-write-prefetch set the socket's TCP_NOTSENT_LOWAT value in bytes and use event based writes
  -t, --time      #        time in seconds to transmit for (default 10 secs)
      --trip-times         enable end to end measurements (requires client and server clock sync)
      --txdelay-time       time in seconds to hold back after connect and before first write
      --txstart-time       unix epoch time to schedule first write and start traffic
  -B, --bind [<ip> | <ip:port>] bind ip (and optional port) from which to source traffic
  -F, --fileinput <name>   input the data to be transmitted from a file
  -H, --ssm-host <ip>      set the SSM source, use with -B for (S,G) 
  -I, --stdin              input the data to be transmitted from stdin
  -L, --listenport #       port to receive fullduplexectional tests back on
  -P, --parallel  #        number of parallel client threads to run
  -R, --reverse            reverse the test (client receives, server sends)
  -S, --tos                IP DSCP or tos settings
  -T, --ttl       #        time-to-live, for multicast (default 1)
  -V, --ipv6_domain        Set the domain to IPv6 (send packets over IPv6)
  -X, --peer-detect        perform server version detection and version exchange

Miscellaneous:
  -x, --reportexclude [CDMSV]   exclude C(connection) D(data) M(multicast) S(settings) V(server) reports
  -y, --reportstyle C      report as a Comma-Separated Values
  -h, --help               print this message and quit
  -v, --version            print version information and quit
```

## Examples <a name="examples"></a>

This example was executed using the following command:

```bash
./run_docker_benchmark.sh alpine pull dind yes 10 both -e
```

The terminal output was:

```
❯ ./run_docker_benchmark.sh alpine pull dind yes 10 both -e
alpine: Pulling from cnuvem23/iperf
Digest: sha256:793704e0cb49b686b7d476fa8414cc6858fb7f3ddc7a3dc5307b518ebdaee947
Status: Image is up to date for cnuvem23/iperf:alpine
docker.io/cnuvem23/iperf:alpine

What's Next?
  View a summary of image vulnerabilities and recommendations → docker scout quickview cnuvem23/iperf:alpine
==========================================================
 Collecting host info
==========================================================
shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.all-release     shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.ifconfig
shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.apt_installed   shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.lsb-release
shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.cpu-info        shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.lsb_release
shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.cpuid           shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.lshw
shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.cpuinfo         shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.lspci
shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.debian_version  shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.lsusb
shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.hdparm          shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.os-release
shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.hostnamectl     shared/outputs-hostinfo-DESKTOP-QO9V79H-20231017/outputs-hostinfo-DESKTOP-QO9V79H.INFO.uname
==========================================================

==========================================================
 Executing benchmark iperf 10 times
==========================================================
dind: Pulling from library/docker
Digest: sha256:f28ffd78641197871fea8fd679f2bf8a1cdafa4dc3f1ce3e700ad964aac2879a
Status: Image is up to date for docker:dind
docker.io/library/docker:dind

What's Next?
  View a summary of image vulnerabilities and recommendations → docker scout quickview docker:dind
Starting Docker in Docker...
Docker in Docker (DinD) started with container ID 240407716f439397e4b5a64295fcf080bfb40f18179901363e4d53d54e9e21bd.
Running docker run --name=iperf-alpine-NDc3Mwo -v /cnuvem23/shared:/cnuvem23/shared -e DISPLAY=unix:0 cnuvem23/iperf:alpine /cnuvem23/shared/run-benchmark-iperf.sh 1000 alpine 10 both -e (Docker in Docker)

------------------------------------------------------------
Starting server... -e

------------------------------------------------------------
Starting client 1... -e
------------------------------------------------------------
Server listening on TCP port 5001 with pid 14
Read buffer size:  128 KByte (Dist bin width=16.0 KByte)
TCP window size:  128 KByte (default)
------------------------------------------------------------
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 56638 connected with 127.0.0.1 port 5001
[  1] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 56638 (sock=4) (peer 2.1.9) on 2023-10-17 17:11:01.083 (UTC)
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  1] 0.00-10.00 sec  49.2 GBytes  42.3 Gbits/sec  458224=1928:31:30:54193:51874:31:34:350103
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  49.2 GBytes  42.2 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 56638 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  49.2 GBytes  42.2 Gbits/sec

------------------------------------------------------------
Starting client 2... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 37872 connected with 127.0.0.1 port 5001
[  2] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 37872 (sock=5) (peer 2.1.9) on 2023-10-17 17:11:11.110 (UTC)
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  2] 0.00-10.00 sec  48.3 GBytes  41.5 Gbits/sec  443134=1567:31:25:46777:44677:25:30:350002
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.00 sec  48.3 GBytes  41.5 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 37872 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.00 sec  48.3 GBytes  41.5 Gbits/sec

------------------------------------------------------------
Starting client 3... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 54924 connected with 127.0.0.1 port 5001
[  3] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 54924 (sock=4) (peer 2.1.9) on 2023-10-17 17:11:21.132 (UTC)
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  3] 0.00-10.01 sec  49.7 GBytes  42.7 Gbits/sec  458283=1561:22:30:50239:48329:29:23:358050
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  49.7 GBytes  42.7 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 54924 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  49.7 GBytes  42.7 Gbits/sec

------------------------------------------------------------
Starting client 4... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 44406 connected with 127.0.0.1 port 5001
[  4] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 44406 (sock=5) (peer 2.1.9) on 2023-10-17 17:11:31.159 (UTC)
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  4] 0.00-10.01 sec  34.1 GBytes  29.2 Gbits/sec  309016=931:28:22:29609:28457:31:28:249910
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.02 sec  34.1 GBytes  29.2 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 44406 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.02 sec  34.1 GBytes  29.2 Gbits/sec

------------------------------------------------------------
Starting client 5... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 48448 connected with 127.0.0.1 port 5001
[  5] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 48448 (sock=4) (peer 2.1.9) on 2023-10-17 17:11:41.207 (UTC)
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  5] 0.00-10.00 sec  32.4 GBytes  27.8 Gbits/sec  293379=946:27:20:27577:26545:26:34:238204
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.02 sec  32.4 GBytes  27.8 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 48448 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.02 sec  32.4 GBytes  27.8 Gbits/sec

------------------------------------------------------------
Starting client 6... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 45514 connected with 127.0.0.1 port 5001
[  6] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 45514 (sock=5) (peer 2.1.9) on 2023-10-17 17:11:51.244 (UTC)
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  6] 0.00-10.00 sec  43.3 GBytes  37.2 Gbits/sec  394429=1382:28:27:39432:37669:27:29:315835
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  43.3 GBytes  37.1 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 45514 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  43.3 GBytes  37.1 Gbits/sec

------------------------------------------------------------
Starting client 7... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  7] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 56726 (sock=4) (peer 2.1.9) on 2023-10-17 17:12:01.259 (UTC)
[  1] local 127.0.0.1 port 56726 connected with 127.0.0.1 port 5001
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  7] 0.00-10.00 sec  49.5 GBytes  42.6 Gbits/sec  456597=1475:28:24:50132:48286:26:28:356598
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  49.5 GBytes  42.5 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 56726 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  49.5 GBytes  42.5 Gbits/sec

------------------------------------------------------------
Starting client 8... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 49210 connected with 127.0.0.1 port 5001
[  8] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 49210 (sock=5) (peer 2.1.9) on 2023-10-17 17:12:11.292 (UTC)
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  8] 0.00-10.00 sec  46.5 GBytes  39.9 Gbits/sec  422266=1605:21:17:40768:39011:26:26:340792
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.02 sec  46.5 GBytes  39.9 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 49210 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.02 sec  46.5 GBytes  39.9 Gbits/sec

------------------------------------------------------------
Starting client 9... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 54732 connected with 127.0.0.1 port 5001
[  9] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 54732 (sock=4) (peer 2.1.9) on 2023-10-17 17:12:21.314 (UTC)
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[  9] 0.00-10.00 sec  46.5 GBytes  39.9 Gbits/sec  426467=1465:31:25:45299:43462:32:35:336118
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  46.5 GBytes  39.9 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 54732 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  46.5 GBytes  39.9 Gbits/sec

------------------------------------------------------------
Starting client 10... -e
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[ 10] local 127.0.0.1%lo port 5001 connected with 127.0.0.1 port 44052 (sock=5) (peer 2.1.9) on 2023-10-17 17:12:31.330 (UTC)
[  1] local 127.0.0.1 port 44052 connected with 127.0.0.1 port 5001
[ ID] Interval        Transfer    Bandwidth       Reads=Dist
[ 10] 0.00-10.00 sec  48.2 GBytes  41.4 Gbits/sec  443944=1521:25:33:48729:46715:34:26:346861
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  48.2 GBytes  41.3 Gbits/sec
------------------------------------------------------------
Client connecting to localhost, TCP port 5001
TCP window size: 2.50 MByte (default)
------------------------------------------------------------
[  1] local 127.0.0.1 port 44052 connected with 127.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.00-10.01 sec  48.2 GBytes  41.3 Gbits/sec
Latest iperf server log: ./shared/outputs-iperf-alpine-server-20231017171101.txt
Average Bandwidth: 38.45 Gbits/sec

------------------------------------------------------------
Execution of iperf completed. Logs saved in: ./shared
Stopping Docker in Docker...
Docker in Docker (DinD) completed.

==========================================================
 ls shared/
==========================================================
outputs-dind-20231017141052.txt            outputs-iperf-alpine-20231017141050.dstats         outputs-iperf-alpine-client-2-20231017171101.txt  outputs-iperf-alpine-client-5-20231017171101.txt  outputs-iperf-alpine-client-8-20231017171101.txt  run-benchmark-iperf.sh
outputs-hostinfo-DESKTOP-QO9V79H-20231017  outputs-iperf-alpine-client-1-20231017171101.txt   outputs-iperf-alpine-client-3-20231017171101.txt  outputs-iperf-alpine-client-6-20231017171101.txt  outputs-iperf-alpine-client-9-20231017171101.txt
outputs-iperf-20231017171101.stats         outputs-iperf-alpine-client-10-20231017171101.txt  outputs-iperf-alpine-client-4-20231017171101.txt  outputs-iperf-alpine-client-7-20231017171101.txt  outputs-iperf-alpine-server-20231017171101.txt
==========================================================
```

### Testing Environment

- Operating System (WSL): Ubuntu 22.04.2 LTS
- Operating System (Host): Windows 10 Pro 22H2
- Processor: Intel(R) Core(TM) i5-9400F CPU @ 2.90GHz
- RAM: 4x8GB DDR4 2666MHz
- SSD: Kingston Skc3000d/2048g NVMe
- Motherboard: Gigabyte B360M
- GPU: NVIDIA GeForce RTX® 3070

Docker version 24.0.5, build ced0996

## References <a name="references"></a>

- [iperf](https://iperf.fr/)
