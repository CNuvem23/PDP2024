<h1 align="center">IOZONE</h1>
<p align="center">The benchmark tests file I/O performance for the following operations: Read, write, re-read, re-write, read backwards, read strided, fread, fwrite, random read, pread ,mmap, aio_read, aio_write</p>


## Table of Contents
- [About](#about)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [References](#references)

## About <a name="about"></a>

IOzone is a filesystem benchmark tool. The benchmark generates and measures a variety of file operations. Iozone has been ported to many machines and runs under many operating systems.

This project aims to automate the execution of IOZONE in a Docker container, allowing the user to perform performance tests in a simple and fast way.

## Requirements <a name="requirements"></a>

To run this experiment by an automatic way, please install [Docker](https://www.docker.com/).

Before testing the application, it is necessary to inform that for some automated functions such as the removal of outliers and the automatic creation of graphs based on the results obtained, it is necessary to install Python and 2 of its libraries (Scipy and Matplotlib) according to the command below:

```bash

sudo apt-get install python3.9
pip install scipy
pip install matplotlib

```

### Manual install requirements (without Docker)

The IOZONE app is cross-platform and can be installed on various operating systems, including AIX, BSDI, HP-UX, IRIX, FreeBSD, Linux, OpenBSD, NetBSD, OSFV3, OSFV4, OSFV5, SCO OpenServer, Solaris, MAC OS X, Windows (95/98/Me/NT/2K/XP), among others.

## Installation <a name="installation"></a>

This project has an automated way to run IOZONE using Docker. No installation is required, just follow the [usage](#usage) instructions.

To manually IOZONE, simply visit the [official tool website](https://www.iozone.org/) and download the version compatible with your operating system.

## Usage <a name="usage"></a>

To run this experiment by an automatic way, please run the following command:

```bash
# Usage: ./run_docker_benchmark.sh <tag:alpine|debian> <cmd:build|pull|local> <mode:docker|dind> <n_times> <additional_client_parameters>
./run_docker_benchmark.sh debian build docker no 8 200
```

This command will run the iozone benchmark tool on a Debian Linux distribution 8 times with 200 MB recording files using docker and save the data obtained by the test in a file within the shared folder without the performance report.

The following is a summary of the parameters that can be used with IOZONE:

```
Usage: iozone [-s filesize_Kb] [-r record_size_Kb ] [-f [path]filename] [-i test] [-E] [-p] [-a] [-A] [-z] [-Z] [-m] [-M] [-t children] [-h] [-o]
[-l min_number_procs] [-u max_number_procs] [-v] [-R] [-x] [-d microseconds] [-F path1 path2...] [-V pattern] [-j stride] [-T] [-C] [-B] [-D] [-G] [-I] [-H depth] [-k depth] [-U mount_point] [-S cache_size] [-O] [-K] [-L line_size] [-g max_filesize_Kb] [-n min_filesize_Kb] [-N] [-Q] [-P start_cpu] [-c] [-e] [-b filename] [-J milliseconds] [-X filename] [-Y filename] [-w] [-W] [-y min_recordsize_Kb] [-q max_recordsize_Kb] [-+m filename] [-+n] [-+N] [-+u ] [ -+d ] [-+p percent_read] [-+r] [-+t ] [-+A #]

-a
Used to select full automatic mode. Produces output that covers all tested file operations for record sizes of 4k to 16M for file sizes of 64k to 512M.
-A
This version of automatic mode provides more coverage but consumes a bunch of time. The –a option will automatically stop using transfer sizes less than 64k once the file size is 32 MB or larger. This saves time. The –A option tells Iozone that you are willing to wait and want dense coverage for small transfers even when the file size is very large.
NOTE: This option is deprecated in Iozone version 3.61. Use –az –i 0 –i 1 instead.
-b filename
Iozone will create a binary file format file in Excel compatible output of results.
-B
Use mmap() files. This causes all of the temporary files being measured to be created and accessed with the mmap() interface. Some applications prefer to treat files as arrays of memory. These applications mmap() the file and then just access the array with loads and stores to perform file I/O.
-c
Include close() in the timing calculations. This is useful only if you suspect that close() is broken in the operating system currently under test. It can be useful for NFS Version 3 testing as well to help identify if the nfs3_commit is working well.
-C
Show bytes transferred by each child in throughput testing. Useful if your operating system has any starvation problems in file I/O or in process management.
-d #
Microsecond delay out of barrier. During the throughput tests all threads or processes are forced to a barrier before beginning the test. Normally, all of the threads or processes are released at the same moment. This option allows one to delay a specified time in
microseconds between releasing each of the processes or threads.
-D
Use msync(MS_ASYNC) on mmap files. This tells the operating system that all the data in the mmap space needs to be written to disk asynchronously.
-e
Include flush (fsync,fflush) in the timing calculations
-E
Used to select the extension tests. Only available on some platforms. Uses pread interfaces.
-f filename
Used to specify the filename for the temporary file under test. This is useful when the unmount option is used. When testing with unmount between tests it is necessary for the temporary file under test to be in a directory that can be unmounted. It is not possible
to unmount the current working directory as the process Iozone is running in this directory.
-F filename filename filename …
Specify each of the temporary file names to be used in the throughput testing. The number of names should be equal to the number of processes or threads that are specified.
-g #
Set maximum file size (in Kbytes) for auto mode.
-G
Use msync(MS_SYNC) on mmap files. This tells the operating system that all the data in the mmap space needs to be written to disk synchronously.
-h
Displays help screen.
-H #
Use POSIX async I/O with # async operations. Iozone will use POSIX async I/O with a bcopy from the async buffers back into the applications buffer. Some versions of MSC NASTRAN perform I/O this way. This technique is used by applications so that the async I/O may be performed in a library and requires no changes to the applications internal model.
-i #
Used to specify which tests to run. (0=write/rewrite, 1=read/re-read, 2=random-read/write 3=Read-backwards, 4=Re-write-record, 5=stride-read, 6=fwrite/re-fwrite, 7=fread/Re-fread, 8=random mix, 9=pwrite/Re-pwrite, 10=pread/Re-pread, 11=pwritev/Re-pwritev, 12=preadv/Repreadv). One will always need to specify 0 so that any of the following tests will have a file to measure. -i # -i # -i # is also supported so that one may select more than one test.
-I
Use DIRECT I/O for all file operations. Tells the filesystem that all operations are to bypass the buffer cache and go directly to disk. This also will use  VX_DIRECT on VxFS, and O_DIRECT on Linux, and directio() on Solaris.
-j #
Set stride of file accesses to (# * record size). The stride read test will read records at this stride.
-J # (in milliseconds)
Perform a compute delay of this many milliseconds before each I/O operation. See also -X and -Y for other options to control compute delay.
-k #
Use POSIX async I/O (no bcopy) with # async operations. Iozone will use POSIX async I/O and will not perform any extra bcopys. The buffers used by Iozone will be handed to the async I/O system call directly.
-K
Generate some random accesses during the normal testing.
-l #
Set the lower limit on number of processes to run. When running throughput tests this option allows the user to specify the least number of processes or threads to start. This option should be used in conjunction with the -u option.
-L #
Set processor cache line size to value (in bytes). Tells Iozone the processor cache line size. This is used internally to help speed up the test.
-m
Tells Iozone to use multiple buffers internally. Some applications read into a single buffer over and over. Others have an array of buffers. This option allows both types of applications to be simulated. Iozone’s default behavior is to re-use internal buffers.
This option allows one to override the default and to use multiple internal buffers.
-M
Iozone will call uname() and will put the string in the output file.
-n #
Set minimum file size (in Kbytes) for auto mode.
-N
Report results in microseconds per operation.
-o
Writes are synchronously written to disk. (O_SYNC). Iozone will open the files with the O_SYNC flag. This forces all writes to the file to go completely to disk before returning to the benchmark.
-O
Give results in operations per second.
-p
This purges the processor cache before each file operation. Iozone will allocate another internal buffer that is aligned to the same processor cache boundary and is of a size that matches the processor cache. It will zero fill this alternate buffer before beginning each test. This will purge the processor cache and allow one to see the memory subsystem without the acceleration due to the processor cache.
-P #
Bind processes/threads to processors, starting with this cpu #. Only available on some platforms. The first sub process or thread will begin on the specified processor. Future processes or threads will be placed on the next processor. Once the total number of cpus is exceeded then
future processes or threads will be placed in a round robin fashion.
-q #
Set maximum record size (in Kbytes) for auto mode. One may also specify -q #k (size in Kbytes) or -q #m (size in Mbytes) or -q #g (size in Gbytes). See –y for setting minimum record size.
-Q
Create offset/latency files. Iozone will create latency versus offset data files that can be imported with a graphics package and plotted. This is useful for finding if certain offsets have very high latencies. Such as the point where UFS will allocate its first indirect block.
One can see from the data the impacts of the extent allocations for extent based filesystems with this option.
-r #
Used to specify the record size, in Kbytes, to test. One may also specify -r #k (size in Kbytes) or -r #m (size in Mbytes) or -r #g (size in Gbytes).
-R
Generate Excel report. Iozone will generate an Excel compatible report to standard out. This file may be imported with Microsoft Excel (space delimited) and used to create a graph of the filesystem performance. Note: The 3D graphs are column oriented. You will need to
select this when graphing as the default in Excel is row oriented data.
-s #
Used to specify the size, in Kbytes, of the file to test. One may also specify -s #k (size in Kbytes) or -s #m (size in Mbytes) or -s #g (size in Gbytes).
-S #
Set processor cache size to value (in Kbytes). This tells Iozone the size of the processor cache. It is used internally for buffer alignment and for the purge functionality.
-t #
Run Iozone in a throughput mode. This option allows the user to specify how many threads or processes to have active during the measurement.
-T
Use POSIX pthreads for throughput tests. Available on platforms that have POSIX threads.
-u #
Set the upper limit on number of processes to run. When running throughput tests this option allows the user to specify the greatest number of processes or threads to start. This option should be used in conjunction with the -l option.
-U mountpoint
Mount point to unmount and remount between tests. Iozone will unmount and remount this mount point before beginning each test. This guarantees that the buffer cache does not contain any of the file under test.
-v
Display the version of Iozone.
-V #
Specify a pattern that is to be written to the temporary file and validated for accuracy in each of the read tests.
-w
Do not unlink temporary files when finished using them. Leave them present in the filesystem.
-W
Lock files when reading or writing.
-x
Turn off stone-walling. Stonewalling is a technique used internally to Iozone. It is used during the throughput tests. The code starts all threads or processes and then stops them on a barrier. Once they are all ready to start then they are all released at the same time. The moment that any of the threads or processes finish their work then the entire test is terminated and throughput is calculated on the total I/O that was completed up to this point. This ensures that the entire measurement was taken while all of the processes or threads were running in parallel. This flag allows one to turn off the stonewalling and see what happens.
-X filename
Use this file for write telemetry information. The file contains triplets of information: Byte offset, size of transfer, compute delay in milliseconds. This option is useful if one has taken a system call trace of the application that is of interest. This allows Iozone to replicate the I/O operations that this specific application generates and provide benchmark results for this file behavior. (if column 1 contains # then the line is a comment)
-y #
Set minimum record size (in Kbytes) for auto mode. One may also specify
-y #k (size in Kbytes) or -y #m (size in Mbytes) or -y #g (size in Gbytes).
See –q for setting maximum record size.
-Y filename
Use this file for read telemetry information. The file contains triplets of information: Byte offset, size of transfer, compute delay in milliseconds. This option is useful if one has taken a system call trace of the application that is of interest. This allows Iozone to replicate the I/O operations that this specific application generates and provide benchmark results for this file behavior. (if column 1 contains # then the line is a comment)
-z
Used in conjunction with -a to test all possible record sizes. Normally Iozone omits testing of small record sizes for very large files when used in full automatic mode. This option forces Iozone to include the small record sizes in the automatic tests also.
-Z
Enable mixing mmap I/O and file I/O.
-+m filename
Use this file to obtain the configuration information of the clients for cluster testing. The file contains one line for each client. Each line has three fields. The fields are space delimited. A # sign in column zero is a comment line. The first field is the name of the client. The second field is the path, on the client, for the working directory where Iozone will execute. The third field is the
path, on the client, for the executable Iozone. To use this option one must be able to execute commands on the clients without being challenged
for a password. Iozone will start remote execution by using “rsh”.
-+n
No retests selected. Use this to prevent retests from running.
-+N
No truncating or deleting of previous test file before the sequential write test. Useful only after -w is used in previous command to leave the test file in place for reuse. This flag is of limited use, when a single retest is not enough, or to easily control when sequential write retests occur without file truncation or deletion.
-+u
Enable CPU utilization mode.
-+d
Enable diagnostic mode. In this mode every byte is validated. This is handy if one suspects a broken I/O subsystem.
-+p percent_read
Set the percentage of the thread/processes that will perform random read testing. Only valid in throughput mode and with more than 1 process/thread.
-+r
Enable O_RSYNC and O_SYNC for all I/O testing.
-+t
Enable network performance test. Requires -+m
-+A
Enable madvise. 0 = normal, 1=random, 2=sequential, 3=dontneed, 4=willneed. For use with options that activate mmap() file I/O. See: -B

```

## Examples <a name="examples"></a>

This example was executed using the following command:

```bash
./run_docker_benchmark.sh debian build dind yes 9 200
```

The terminal output was:

```
Executando teste 1 de 9...
Teste 1 concluído em 4 microssegundos.
Executando teste 2 de 9...
Teste 2 concluído em 4 microssegundos.
Executando teste 3 de 9...
Teste 3 concluído em 3 microssegundos.
Executando teste 4 de 9...
Teste 4 concluído em 3 microssegundos.
Executando teste 5 de 9...
Teste 5 concluído em 4 microssegundos.
Executando teste 6 de 9...
Teste 6 concluído em 3 microssegundos.
Executando teste 7 de 9...
Teste 7 concluído em 3 microssegundos.
Executando teste 8 de 9...
Teste 8 concluído em 4 microssegundos.
Executando teste 9 de 9...
Teste 9 concluído em 3 microssegundos.
Tempo total gasto em microssegundos: 31
Tempo medio gasto em microssegundos: 3.444444
Desvio padrão gasto em microssegundos: 1.855921
Tempo do teste mais longo em microssegundos: 4
Tempo do teste mais curto em microssegundos: 3
iozone-alpine-OTM0Nwo
outputs-iozone-alpine-20231016183739_1.xls  outputs-iozone-alpine-20231016183739_7.xls
outputs-iozone-alpine-20231016183739_2.xls  outputs-iozone-alpine-20231016183739_8.xls
outputs-iozone-alpine-20231016183739_3.xls  outputs-iozone-alpine-20231016183739_9.xls
outputs-iozone-alpine-20231016183739_4.xls  outputs-iozone_results.txt
outputs-iozone-alpine-20231016183739_5.xls  run-benchmark-iozone.sh
outputs-iozone-alpine-20231016183739_6.xls

```

The output files contain the data collected during each of the tests carried out in an original way, without any treatment or change in their values.

## Removing Outliers
In statistics, an outlier, aberrant value or atypical value, is an observation that differs greatly from the others in the series, or that is inconsistent. The existence of outliers typically implies prejudice to the interpretation of the results of statistical tests applied to the samples.

Thinking about creating more accurate and more realistic samples, the outliers.py script was implemented. To run it, first go into the Scripts folder:

```bash

cd shared/

```

Then run the python command to call the outlier removal script informing the name of the file from which you want to remove the outliers:

```bash

python3 outliers.py outputs-iozone-alpine-xxxxxx-estatistica.txt

```
It will generate a file called: outputs-iozone-alpine-xxxxx-outliers.txt containing all the results except the outliers.

## Generating the Graphs

Now, to be able to generate the graphs automatically, saving them with the .png extension and the name outputs-grafico-iozone-xxxxxx.png (xxxx is the current date and time), it is necessary to execute the command below:

```bash

python3 graficos.py outputs-iozone-alpine-xxxxxx-outliers.txt

```

It is worth remembering that, in your terminal, it must be inside the shared folder and that the xxxx in the command must be replaced with the correct name of the file you want the image to be read and created!!

## References <a name="references"></a>

- [IOZONE](https://www.iozone.org/docs/IOzone_msword_98.pdf)
