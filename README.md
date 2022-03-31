# Get info on cpu & nic & drives

getinfo.sh is a bash script providing basic info on hw:

* cpu (models and core numbers)
* nics (model numbers, and link state)
* drives (logical and model name)

## Pre requirements

Required to run this program are basic linux tools:

* lscpi and lshw
* is missing can install using your local package manager, below are examples for yum and apt.

```bash
yum install pciutils; yum install lshw;
apt-get install pciutils; apt-get install lshw;
```

## To run the code:
```
./getinfo.sh     # saves to directories only
./getinfo.sh -s  # shows output on screen as well directories
```

The code then generates files with the hostname & run date to cpu, nic, and drives directory

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

# Tips:

To see output in all dirs:
```bash
grep -r . cpu nic drives
```

To delete output in all dirs, to have clean output
```bash
rm -f cpu/* nic/* drives/*
```