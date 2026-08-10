# Linux File System

## Definition
The **Linux File System** is a hierarchical directory structure used to
organize and store files and directories. Everything in Linux starts
from the **root (`/`)** directory.

------------------------------------------------------------------------
## Linux File System Architecture
``` text
                    /
                    │
 ├── /bin
 ├── /boot
 ├── /dev
 ├── /etc
 ├── /home
 ├── /lib
 ├── /media
 ├── /mnt
 ├── /opt
 ├── /proc
 ├── /root
 ├── /run
 ├── /sbin
 ├── /srv
 ├── /sys
 ├── /tmp
 ├── /usr
 └── /var
```
------------------------------------------------------------------------
## Most Important Directories for DevOps
  -----------------------------------------------------------------------
  Directory                               Purpose
  --------------------------------------- -------------------------------
  `/etc`                                  Stores system and application
                                          configuration files (SSH,
                                          Nginx, Docker, systemd, etc.).
  `/var/log`                              Stores system and application
                                          log files.
  `/home`                                 Home directories for normal
                                          users.
  `/tmp`                                  Stores temporary files.
  `/proc`                                 Virtual file system containing
                                          process and kernel information.
  `/boot`                                 Stores boot-related files such
                                          as the Linux kernel and GRUB
                                          configuration.
  `/usr`                                  Contains user applications,
                                          libraries, and system commands.
  `/opt`                                  Stores optional or third-party
                                          software packages.
  -----------------------------------------------------------------------
------------------------------------------------------------------------
## Quick Interview Summary
> The **Linux File System** is a hierarchical directory structure that
> starts from the **root (`/`)** directory. It organizes files and
> directories in a standardized manner. The most important directories
> for DevOps are **`/etc`** (configuration files), **`/var/log`**
> (logs), **`/home`** (user data), **`/boot`** (boot files), **`/proc`**
> (process and kernel information), **`/tmp`** (temporary files),
> **`/usr`** (applications and libraries), and **`/opt`** (third-party
> software).

