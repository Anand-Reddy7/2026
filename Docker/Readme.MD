## Docker
Docker is a tool that lets you package and run applications in isolated environments called containers.

### Container
A container is an isolated process running on the host OS, with its own view of things such as:

- Processes
- Network interfaces
- Filesystem
- Hostname
- Users
- Resource limits

Note: containers use the same host kernel.

### Advantages

- Portability – Run the same application on a laptop, server, or cloud.
- Consistency – The application behaves the same across different environments.
- Isolation – Applications and their dependencies are separated from each other.
- Lightweight & Fast – Containers use fewer resources and start much faster than virtual machines.
- Easy Scaling – You can quickly create multiple containers when application traffic increases.

### How Does Linux Actually Isolate Containers?

1. Namespaces – Isolation
- Give each container its own view of the system.
- A container can have its own processes, network, hostname, users, and filesystems.
- For example, a process inside Container A normally cannot see processes inside Container B.

2. cgroups – Resource Control
- Control how much CPU, memory, disk I/O, etc. a container can use.
- Example: you can limit a container to 2 GB RAM and 1 CPU.

3. Linux Capabilities – Permissions
- Break the powerful root privileges into smaller permissions.
- A container can be prevented from performing dangerous operations even if a process runs as root inside the container.

4. Security mechanisms – Protection
- Technologies such as SELinux, AppArmor, and seccomp can restrict what a container is allowed to access or which system calls it can make.

5. Union/Layered Filesystems – Filesystem Isolation
- Docker uses layered filesystems so each container gets its own filesystem view without needing a complete copy of the underlying OS.

```
                 Linux Kernel
                     │
       ┌─────────────┴─────────────┐
       │                           │
  Container A                 Container B
       │                           │
  Namespaces                  Namespaces
  cgroups                     cgroups
  Capabilities                Capabilities
  Security                    Security
       │                           │
       └─────────────┬─────────────┘
                     │
              Shared Linux Kernel
```

### A container can have its own:
```
PID namespace
Network namespace
Mount namespace
UTS namespace
IPC namespace
User namespace
```
### Why is PID 1 Important in Container?
PID 1 is important in a container because the first process started inside the container gets Process ID 1, and it has special responsibilities.

#### Why PID 1 matters:
- It is the main process – The first process launched in the container becomes PID 1.
- It controls the container's lifetime – When PID 1 exits, the container normally stops.
- It handles signals – PID 1 needs to properly handle signals such as SIGTERM when the container is asked to shut down.
- It reaps zombie processes – PID 1 is responsible for cleaning up orphaned child processes that become zombies.
- It affects graceful shutdown – If PID 1 doesn't handle signals correctly, applications may not shut down cleanly and can take longer to stop.

## Docker Architecture

```text
                         User
                          |
                          v
                     Docker CLI
                          |
                          | API
                          v
                    Docker Engine
                       dockerd
                    /     |      \
                   /      |       \
                  v       v        v
             Images    Networks   Volumes
                  |
                  v
              containerd
                  |
                  v
                runc
                  |
                  v
           Linux Kernel
        /       |        \
 namespaces   cgroups   networking
```

# Docker Internal Architecture: How Docker Creates and Runs Containers

This document explains the **internal Docker architecture**, specifically how Docker creates a container and how Linux kernel features isolate and run it.

## Docker → Container → Linux Kernel

```text
                         USER
                          │
                          │ docker run nginx
                          ▼
                ┌───────────────────┐
                │   Docker Client   │
                │     (docker)      │
                └─────────┬─────────┘
                          │ Docker API
                          ▼
                ┌───────────────────┐
                │   Docker Daemon   │
                │     dockerd       │
                └─────────┬─────────┘
                          │
                          ▼
                ┌───────────────────┐
                │    containerd     │
                │ Container Manager │
                └─────────┬─────────┘
                          │
                          ▼
                ┌───────────────────┐
                │       runc        │
                │ Container Runtime │
                └─────────┬─────────┘
                          │
              Uses Linux Kernel Features
                          │
       ┌──────────────────┼──────────────────┐
       ▼                  ▼                  ▼
  Namespaces            cgroups         Capabilities
  "What I see"        "What I use"      "What I can do"
       │                  │                  │
       └──────────────────┼──────────────────┘
                          ▼
                 ┌─────────────────┐
                 │  Linux Kernel   │
                 └────────┬────────┘
                          │
                          ▼
                ┌───────────────────┐
                │     Container     │
                │                   │
                │ PID 1             │
                │ nginx             │
                │ filesystem        │
                │ network           │
                └───────────────────┘
```

## What happens when you run `docker run nginx`?

### 1. Docker Client

You type:

```bash
docker run nginx
```

The Docker CLI sends this request to `dockerd`.

### 2. Docker Daemon

`dockerd` determines what is needed:

```text
"Do I have the nginx image?"
          │
     ┌────┴────┐
     │         │
    YES        NO
     │         │
     │         ▼
     │    Docker Registry
     │         │
     │      Pull image
     │         │
     └────┬────┘
          ▼
    Create container
```

### 3. containerd

Docker uses **containerd** to manage the container lifecycle.

It handles things such as:

- Creating the container
- Managing the container
- Starting/stopping it
- Managing its filesystem and runtime

### 4. runc

`runc` is responsible for actually creating and starting the container using Linux kernel functionality.

This is where the important isolation happens.

## How Linux Creates the Isolation

`runc` asks the Linux kernel to create isolated environments.

### Namespaces → Isolation

Linux namespaces provide separate views:

```text
Container
│
├── PID Namespace
│     └── nginx sees itself as PID 1
│
├── Network Namespace
│     ├── eth0
│     └── its own IP/network
│
├── Mount Namespace
│     └── its own filesystem view
│
├── UTS Namespace
│     └── its own hostname
│
└── User Namespace
      └── isolated users/UIDs
```

So inside the container:

```bash
ps
```

might show:

```text
PID
1
```

while the host has many other processes.

## cgroups → Resource Limits

Linux **cgroups** control resources:

```text
Container
   │
   ├── CPU → 1 CPU
   ├── Memory → 512 MB
   ├── Disk I/O → Limited
   └── Processes → Maximum 100
```

This prevents one container from consuming all the host's resources.

## Capabilities → Permissions

Linux capabilities restrict what the container can do.

Instead of giving a container unrestricted root privileges:

```text
Container
    │
    └── Root
         │
         ├── Allowed capability
         ├── Allowed capability
         └── Restricted capability ❌
```

## Filesystem → Container's File View

Docker uses a layered filesystem.

For example:

```text
          Container
              │
       ┌───────────────┐
       │ Writable Layer│
       ├───────────────┤
       │ nginx Layer   │
       ├───────────────┤
       │ Ubuntu Layer  │
       └───────────────┘
```

The container sees this as its own filesystem.

## The Most Important Concept

A container **does NOT contain its own Linux kernel**.

Instead:

```text
┌──────────────────────────────────────┐
│              Linux Host              │
│                                      │
│  ┌──────────┐      ┌──────────┐     │
│  │Container │      │Container │     │
│  │    A     │      │    B     │     │
│  └────┬─────┘      └────┬─────┘     │
│       │                 │            │
│       └────────┬────────┘            │
│                ▼                     │
│         ┌──────────────┐             │
│         │ Linux Kernel │             │
│         └──────────────┘             │
└──────────────────────────────────────┘
```

Both containers use the **same Linux kernel**, but Linux namespaces, cgroups, capabilities, seccomp, and other security mechanisms make them behave like isolated environments.

## Easy Formula to Remember

```text
Docker
  ↓
containerd
  ↓
runc
  ↓
Linux Kernel
  ↓
┌─────────────────────────────────┐
│ Namespaces    → Isolation       │
│ cgroups       → Resources       │
│ Capabilities  → Permissions     │
│ seccomp       → System calls    │
│ Filesystem    → File isolation  │
└─────────────────────────────────┘
  ↓
Container Process (PID 1)
```

### Summary

**Docker provides the user-facing experience, containerd manages the container lifecycle, runc creates and starts the container, and the Linux kernel provides the actual isolation and resource-control mechanisms.**


# Docker vs containerd vs runc

This is worth memorizing clearly.

```text
Component	      Role

Docker CLI	      User interface
dockerd	          Docker Engine/daemon
containerd	      Container lifecycle & runtime management
runc	          Low-level OCI container runtime
Linux kernel	  Provides namespaces, cgroups, networking, etc.
```

# Key Reasons Why Containers Are Lightweight

Containers are lightweight because they share the host operating system's kernel instead of running a full, dedicated guest operating system for each application.

### Key Reasons Why Containers Are Lightweight :

• Shared OS Kernel: Instead of virtualizing hardware and booting an entire operating system, containers use the underlying IBM host's kernel, network stack, and drivers. 

• No Guest Operating System: Traditional virtual machines need a full operating system copy. Containers omit this entirely, reducing their storage footprint to just megabytes instead of gigabytes. 

• Process-Level Isolation: Containers isolate applications using lightweight mechanisms like Linux namespaces and control groups () rather than heavy hardware emulation or hypervisors. 

• No Heavy Initialization: Because there is no separate operating system to boot, containers start, stop, and scale almost instantly.



# Docker Installation

```shell
sudo dnf install -y dnf-plugins-core

# add Docker's official repository
sudo dnf config-manager --add-repo \
https://download.docker.com/linux/rhel/docker-ce.repo

# List out the available repolist 
dnf repolist | grep docker

# Install Docker and containerd
sudo dnf install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

# Enable Docker
sudo systemctl enable --now docker
```



## Docker Images commands

```shell
docker search httpd
docker pull httpd
docker image ls
docker image inspect
docker history
docker tag
docker push
docker rmi
docker image prune
docker system df
docker build
docker images --digests
```

## Docker Container commands

```shell
docker ps
docker ps -a
docker rm -f conainer_id
docker run nginx
docker run -d --name nginx-web -p 8080:80 nginx:latest
```

```shell
docker run -d \
  --name nginx-prod \
  -p 8080:80 \
  --restart unless-stopped \
  -v /opt/nginx/html:/usr/share/nginx/html:ro \
  -e ENVIRONMENT=production \
  --network bridge \
  --memory 512m \
  --cpus 1 \
  --read-only \
  --user 101:101 \
  --cap-drop ALL \
  nginx:latest
```

```shell
docker run --rm alpine sh -c 'id; touch /data/test.txt'
Note: Here '-rm' means --> utomatically remove the container after it exits.
```

## Docker Volume 

```text
| Type            | Example          | Data stored where?      | Common use                     |
| --------------- | ---------------- | ----------------------- | ------------------------------ |
| **Volume**      | `mydata:/data`   | Docker-managed location | Databases, persistent app data |
| **Bind mount**  | `/opt/app:/data` | Specific host directory | Configs, logs, source code     |
| **tmpfs mount** | `tmpfs:/data`    | Host memory (RAM)       | Temporary/sensitive data       |

Note: 
- Once the container stops, the data is gone.
- Good for temporary data where you don't want it written to disk.
```

## Docker Networking

```text
| Docker network | Real-time example                                                                                                         |
| -------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **bridge**     | Nginx + Backend + Redis/PostgreSQL containers                                                                             |
| **host**       | Network monitoring agent like Prometheus Node Exporter, packet/network monitoring tools, high-performance networking apps |
| **none**       | Security-isolated batch job, file processing/conversion container, offline data processing                                |
```

```shell
docker network ls
docker network create my_network --driver=bridge
docker network inspect bridge
docker network ls
docker network inspect <network>
docker network create <network>
docker network connect <network> <container>
docker network disconnect <network> <container>
docker network rm <network>
docker network prune
```

## DockerFile

```shell
FROM nginx:latest

LABEL maintainer="anand"

WORKDIR /usr/share/nginx/html

ENV SERVER=Production

ARG APP_VERSION

COPY . /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

## Others

USER nginx
HEALTHCHECK CMD curl -f http://localhost/ || exit 1

## Create a Docker Image with specific file
docker build -f my_docker_file  -t myapp:dev .
```

## Other Dockercommands

```shell
docker top conatiner_id
docker stats  conatiner_id
docker port  conatiner_id
docker login -u xxxx
```

## Multi Staged Docker Images 
Multi-stage Docker builds use multiple stages in a Dockerfile. We use one stage to build the application with all required tools, and a separate lightweight stage to run it. We copy only the required artifacts into the final image, which makes the image smaller, faster, and more secure.

```text
Smaller image
Faster image pull
Faster deployment
Smaller attack surface
Fewer unnecessary packages
Cleaner production containers
```


```shell
FROM golang:1.25 AS builder

WORKDIR /app

COPY main.go .

RUN go build -o myapp main.go


FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/myapp .

CMD ["./myapp"]
```


# Docker Swarm

Think of Docker Swarm as multiple Docker machines working together as one cluster.

