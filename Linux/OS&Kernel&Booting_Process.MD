# Linux Fundamentals -- Quick Revision Notes

## 1. Operating System (OS)

### Definition

An **Operating System (OS)** is system software that acts as an
interface between the user/applications and the computer hardware. It
manages hardware resources and provides services for applications to
run.

### Main Components / Responsibilities

-   **Process Management** -- Manages running processes and CPU
    scheduling.
-   **Memory Management** -- Allocates and frees RAM, manages virtual
    memory.
-   **File System Management** -- Creates, reads, writes, and organizes
    files.
-   **Device Management** -- Controls hardware using device drivers.
-   **Networking** -- Manages network communication (TCP/IP, sockets).
-   **Security** -- User authentication, permissions, and access
    control.
-   **User Interface** -- CLI (Shell) or GUI for user interaction.

### Examples

-   Ubuntu
-   RHEL
-   Rocky Linux
-   Debian
-   Windows
-   macOS


## Different Types of Operating Systems

### 1. Desktop OS

Used on personal computers and laptops.

**Examples:**

- Windows
- macOS
- Ubuntu Desktop
- Fedora

### 2. Server OS

Designed to run services and applications for many users or systems.

**Examples:**

- RHEL
- Ubuntu Server
- SUSE Linux
- Windows Server

**Commonly used for:**

- Web Servers
- Database Servers
- Cloud Infrastructure
- HPC
- File Servers
- Application Servers

### 3. Mobile OS

Designed for smartphones and tablets.

**Examples:**

- Android
- iOS

**Interesting point:**

Android uses the Linux kernel underneath.

### 4. Embedded OS

Designed for dedicated devices.

**Examples:**

- Cars
- Routers
- Smart TVs
- IoT devices
- Industrial equipment

------------------------------------------------------------------------

## 2. Linux Kernel

### Definition

The **Linux Kernel** is the core of the Linux operating system. It acts
as a bridge between applications and hardware and manages all system
resources.

### Responsibilities

-   Process Management
-   Memory Management
-   Device Drivers
-   File System
-   Networking
-   Security
-   System Calls

### Key Points

-   Heart of Linux
-   Loaded during boot
-   Runs until shutdown
-   Monolithic kernel
-   Open source

### Note:

- ( Kernel, Shell, SystemUtilities, System Libraries, FIle System, Device Drivers etc .. )  An operating system consists of several key components: the Kernel, which is the core responsible for managing hardware resources; the Shell, which provides the user interface to interact with the system; System Libraries, which offer APIs for applications; System Utilities, which are administrative and user commands; the File System, which manages files and directories; Device Drivers, which enable communication with hardware; and Applications, which run on top of the operating system using these services. Together, these components provide a complete computing environment.

+--------------------------------------+
|            Applications              |
| Docker | Python | Nginx | Terraform  |
+--------------------------------------+
|          System Utilities            |
| ls | cp | ps | top | grep | systemctl|
+--------------------------------------+
|         System Libraries             |
| glibc | OpenSSL | libpthread         |
+--------------------------------------+
|              Shell                   |
| bash | sh | zsh | ksh                |
+--------------------------------------+
|              Kernel                  |
| Process | Memory | File System       |
| Networking | Drivers | Security      |
+--------------------------------------+
|             Hardware                 |
| CPU | RAM | Disk | NIC | USB | GPU   |
+--------------------------------------+

------------------------------------------------------------------------

## 3. RHEL (Red Hat Enterprise Linux)

### Definition

**RHEL** is an enterprise Linux operating system developed by Red Hat,
built on the Linux kernel, and designed for production environments.

### Features

-   Enterprise Support
-   Long-Term Support (LTS)
-   Security Updates
-   Stable Releases
-   Hardware & Software Certification

### Common Enterprise Tools

-   SELinux
-   systemd
-   Podman
-   DNF/YUM
-   Firewalld
-   LVM

------------------------------------------------------------------------

## Quick Interview Summary

  -----------------------------------------------------------------------
  Topic                  One-Line Answer
  ---------------------- ------------------------------------------------
  **Operating System     Manages hardware and provides an environment for
  (OS)**                 applications to run.

  **Linux Kernel**       Core of the OS that manages CPU, memory,
                         devices, networking, and system calls.

  **RHEL**               Enterprise Linux distribution built on the Linux
                         kernel with commercial support and long-term
                         stability.
  -----------------------------------------------------------------------




# 3. Linux Boot Process (Quick Revision)

## Architecture
``` text
Power ON
    ↓
BIOS / UEFI
    ↓
GRUB (Boot Loader)
    ↓
Linux Kernel
    ↓
systemd
    ↓
Login Prompt
```

## 1. BIOS / UEFI
-   Performs **POST (Power-On Self-Test)** to verify hardware.
-   Finds the bootable device and loads the boot loader.
## 2. GRUB (Boot Loader)
-   Displays the boot menu (if multiple OS/kernel versions exist).
-   Loads the Linux kernel into memory.
## 3. Linux Kernel
-   Initializes CPU, memory, storage, and hardware devices.
-   Starts the first user-space process (`systemd`).
## 4. systemd
-   Starts essential system services (SSH, Network, Docker, etc.).
-   Manages and monitors services throughout system operation.
## 5. Login Prompt
-   Displays the CLI or GUI login screen.
-   Allows users to log in and start using the system.

------------------------------------------------------------------------
## Interview Answer
> When a Linux system is powered on, BIOS/UEFI checks the hardware and
> locates the bootable device. GRUB then loads the Linux kernel into
> memory. The kernel initializes the hardware and starts `systemd`,
> which launches essential services. Finally, the login prompt is
> displayed, and the system is ready for use.

