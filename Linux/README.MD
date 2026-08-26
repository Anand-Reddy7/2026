##  What Happens When You Read a File in Linux?


When you run a command such as cat /home/user/test.txt, the cat application requests the Linux kernel to open and read the file using system calls such as open() and read(). The kernel identifies the process and its user credentials, then resolves the file path and checks whether the file exists. It verifies the user's permissions by checking the file's owner, group, permission bits, and any applicable ACLs or security policies such as SELinux. 

Once access is allowed, the kernel identifies the file system and retrieves the file's metadata, including the location of the file's data. The kernel then checks the page cache to see whether the required data is already available in RAM. If the data is cached, it can return the data directly without accessing the disk. If the data is not cached, the kernel asks the file system to locate the required blocks, which are then accessed through the block layer and storage driver. The SSD or HDD reads the required data and returns it back through the storage driver, block layer, and file system to the kernel. The kernel then makes the data available to the application, and cat writes the contents to the terminal.

## Generic Software Installation Process ?

1. Package manager finds the software in configured repositories.
2. It resolves and downloads the software and required dependencies.
3. Packages are verified and installed on the system.
4. Required files, configuration, libraries, and services are created/registered.
5. Software is now installed and ready to be configured/started.

```
Repository → Download → Dependencies → Install → Configure/Start
```

### Example: Installing Nginx
```
yum install nginx -y
```

### What happens:
```
1. YUM finds Nginx in the configured repository.
2. Downloads Nginx and its dependencies.
3. Verifies and installs the RPM packages.
4. Creates Nginx files, configuration, and systemd service.
5. Nginx is installed and ready to configure/start.
```

### In short:

```
Repository → Download → Dependencies → Install → Ready
```


### Add a Third-Party Repository Manually

Repository configuration files are stored in:
```
/etc/yum.repos.d/
```

1. Create a .repo file:
```
sudo vi /etc/yum.repos.d/myrepo.repo
```

2. Add repository details:
```
[myrepo]
name=My Third Party Repository
baseurl=https://example.com/repo/
enabled=1
gpgcheck=1
gpgkey=https://example.com/RPM-GPG-KEY
```

3. Verify the repository:
```
sudo yum repolist
```

4. Install the required software:
```
sudo yum install <software> -y
```

Simple Flow
```
Create .repo file
      ↓
/etc/yum.repos.d/
      ↓
yum repolist
      ↓
yum install <software>
```

Note: Use the repository URL and GPG key provided by the official software vendor.

### Add Third-Party Repository — Summary

1. Create a `.repo` file under `/etc/yum.repos.d/`.
2. Add repository URL, enable it, and configure GPG verification.
3. Run `yum repolist` to verify the repository.
4. Install software using `yum install <software>`.

Flow:
```
.repo file → /etc/yum.repos.d/ → yum repolist → yum install
```

## The package you need isn't available in the configured repository. What would you do?

If the software is not available in any configured/enabled repository, yum cannot install it.

First I would check the enabled repositories and confirm whether the package is available in another approved repository. If not, I would use the vendor's trusted repository or obtain the RPM through our approved package-management process. For restricted or offline environments, I may download the RPM and its dependencies separately. Building from source would be my last option unless there's a specific requirement."

                YUM
                 |
                 v
       Search configured repos
                 |
        +--------+--------+
        |                 |
      Found             Not Found
        |                 |
        v                 v
     Install       Find a suitable
                   source/repository
                         |
              +----------+----------+
              |          |          |
            Repo       RPM       Source


## Expline the below command 
```
[root@anand-vsi-dnd nginx]# getent passwd nginx
nginx:x:991:988:Nginx web server:/var/lib/nginx:/sbin/nologin
```

### The /etc/passwd format is:

```
username : password : UID : GID : comment : home_directory : login_shell
```

So yours means:
```
nginx
  |
  +-- Username:       nginx
  +-- Password:       x
  +-- UID:            991
  +-- GID:            988
  +-- Description:    Nginx web server
  +-- Home:           /var/lib/nginx
  +-- Shell:          /sbin/nologin

```
### Important point

```
/sbin/nologin
```

- means the nginx user cannot normally log in interactively.

- This is intentional for security.

- The Nginx worker processes can run as the nginx user without giving that user an interactive shell.

- You can verify the running processes with:
```
ps -ef | grep '[n]ginx'
```

- You'll typically see:
```
root   nginx: master process
nginx  nginx: worker process
nginx  nginx: worker process
```

- This demonstrates an important Nginx concept:
```
Master process runs as root; worker processes run as the less-privileged nginx user.
```

## How to get the Nginx Deamon service file ? 

```
[root@anand-vsi-dnd nginx]# systemctl cat nginx
# /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
[root@anand-vsi-dnd nginx]#
```

## How to check a specific package when it installed?
```
rpm -q --last nginx
```

```
[root@anand-server-1-rhel ~]# 
[root@anand-server-1-rhel ~]# rpm -q --last tree
tree-1.7.0-15.el8.x86_64                      Sun 23 Aug 2026 12:30:34 PM UTC
[root@anand-server-1-rhel ~]# date 
Sun Aug 23 12:31:46 UTC 2026
[root@anand-server-1-rhel ~]# rpm -qi tree
Name        : tree
Version     : 1.7.0
Release     : 15.el8
Architecture: x86_64
Install Date: Sun 23 Aug 2026 12:30:34 PM UTC
Group       : Unspecified
Size        : 111611
License     : GPLv2+
Signature   : RSA/SHA256, Wed 07 Nov 2018 05:20:51 PM UTC, Key ID 199e2f91fd431d51
Source RPM  : tree-1.7.0-15.el8.src.rpm
Build Date  : Wed 07 Nov 2018 04:49:35 PM UTC
Build Host  : x86-vm-10.build.eng.bos.redhat.com
Relocations : (not relocatable)
Packager    : Red Hat, Inc. <http://bugzilla.redhat.com/bugzilla>
Vendor      : Red Hat, Inc.
URL         : http://mama.indstate.edu/users/ice/tree/
Summary     : File system tree viewer
Description :
The tree utility recursively displays the contents of directories in a
tree-like format.  Tree is basically a UNIX port of the DOS tree
utility.
[root@anand-server-1-rhel ~]# 
```