# Linux File System

## Definition

The **Linux File System** is a hierarchical directory structure used to organize and store files and directories. Everything in Linux starts from the **root (`/`)** directory.

---

## Linux File System Architecture

```text
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

---

## Most Important Directories for DevOps

| Directory | Purpose |
|---|---|
| `/` | Root of the entire Linux file system. |
| `/bin` | Essential user commands and binaries. |
| `/boot` | Files required for the system boot process, including the Linux kernel and bootloader files. |
| `/dev` | Device files representing hardware and virtual devices. |
| `/etc` | System-wide configuration files. |
| `/home` | Home directories and personal data of regular users. |
| `/lib` | Essential shared libraries and kernel modules. |
| `/media` | Mount points for removable media such as USB drives. |
| `/mnt` | Temporary mount point commonly used for manually mounted file systems. |
| `/opt` | Optional or third-party software packages. |
| `/proc` | Virtual file system providing process and kernel information. |
| `/root` | Home directory of the root user. |
| `/run` | Runtime data created by processes and services since boot. |
| `/sbin` | System administration commands and binaries. |
| `/srv` | Data served by system services. |
| `/sys` | Virtual file system providing information about devices and the kernel. |
| `/tmp` | Temporary files created by users and applications. |
| `/usr` | User applications, libraries, documentation, and other read-only/shareable data. |
| `/var` | Variable data such as logs, caches, queues, and application data. |

---

## Quick Interview Summary

> The **Linux File System** is a hierarchical directory structure that starts from the **root (`/`)** directory. It organizes files and directories in a standardized manner. The most important directories for DevOps are **`/etc`** (configuration files), **`/var/log`** (logs), **`/home`** (user data), **`/boot`** (boot files), **`/proc`** (process and kernel information), **`/tmp`** (temporary files), **`/usr`** (applications and libraries), and **`/opt`** (third-party software).
