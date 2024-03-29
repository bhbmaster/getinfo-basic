# Get info on cpu & nic & drives

getinfo.sh is a bash script providing basic info on hw:

* cpu (models and core numbers)
* nics (model numbers, and link state)
* drives (logical and model name)


Tested on the following platforms:
* Ubuntu 20.04 running on WSL2 - kernel: 5.10.102.1-microsoft-standard-WSL2 
* Debian 8 running on ReadyNAS 6.10 code - kernel: 4.4.218.x86_64.1

## Pre requirements

Required to run this program are basic linux tools:

* lscpi and lshw
* if missing can install using your local package manager, below are examples for yum and apt.

```bash
yum install pciutils; yum install lshw;
apt-get install pciutils; apt-get install lshw;
```

## To run the code:
```
./getinfo.sh     # saves to directories only
./getinfo.sh -s  # shows output on screen as well directories
```

The code then generates files named with the hostname & run date "<hostname>-<date>.out" to cpu, nic, and drives directory.
These directories are created in the script's root directory, and not your current working directory.

```
root@starlord2:~/lbl-kk# tree cpu nic drives
cpu
├── starlord2-220331-161634.out
└── starlord2-220331-161707.out
nic
├── starlord2-220331-161634.out
└── starlord2-220331-161707.out
drives
├── starlord2-220331-161634.out
└── starlord2-220331-161707.out
```

## Tips:

To see output in all dirs:
```bash
grep -r . cpu nic drives
```

To delete output in all dirs, to have clean output
```bash
rm -f cpu/* nic/* drives/*
```

## Example output

These are example results from my Debian NAS server.

```bash
root@starlord2:~/lbl-kk# ./getinfo.sh

root@starlord2:~/lbl-kk# cat cpu/*
* cpu model name: Pentium(R) Dual-Core CPU E5300 @ 2.60GHz
* cpu core count: 2

root@starlord2:~/lbl-kk# cat nic/*
* eth0 - link state: down - model name: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 22)
* eth1 - link state: up - model name: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 22)

root@starlord2:~/lbl-kk# cat drives/*
* sda - model name: ST4000DM000-1F21
* sdb - model name: ST4000DM000-1F21
* sdc - model name: ST4000DM000-1F21
* sdd - model name: ST4000DM000-1F21
* sde - model name: ST4000DM000-1F21
* sdf - model name: ST4000DM000-1F21

root@starlord2:~/lbl-kk# find cpu nic drives -type f
cpu/starlord2-220331-162932.out
nic/starlord2-220331-162932.out
drives/starlord2-220331-162932.out

root@starlord2:~/lbl-kk# ./getinfo.sh -s
CPU:
* cpu model name: Pentium(R) Dual-Core CPU E5300 @ 2.60GHz
* cpu core count: 2
NETWORK:
* eth0 - link state: down - model name: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 22)
* eth1 - link state: up - model name: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 22)
DRIVES:
* sda - model name: ST4000DM000-1F21
* sdb - model name: ST4000DM000-1F21
* sdc - model name: ST4000DM000-1F21
* sdd - model name: ST4000DM000-1F21
* sde - model name: ST4000DM000-1F21
* sdf - model name: ST4000DM000-1F21
```

## Caveats

* If lspci doesn't have output, NIC models will be listed as not available "N/A" as that info is in lspci. For example if run from WSL2, it cannot get the NIC models as they are virtual.
