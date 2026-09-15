# Packer

Packer is a tool for automating the creation of machine images.

## Installation

```shell
sudo dnf install -y dnf-plugins-core

sudo dnf config-manager \
  --add-repo \
  https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

sudo dnf install -y packer
```

## Architecture 

```text
                    PACKER HOST
                        │
                 .pkr.hcl template
                        │
             ┌──────────┴──────────┐
             │                     │
             ▼                     ▼
          AWS Plugin          IBM Cloud Plugin
             │                     │
       amazon-ebs             ibmcloud-vpc
             │                     │
             ▼                     ▼
      Temporary EC2          Temporary VSI
             │                     │
             └──────────┬──────────┘
                        │
                 Communicator
                   SSH / WinRM
                        │
                        ▼
                   Provisioners
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
      shell            file           ansible
        │               │               │
        └───────────────┼───────────────┘
                        ▼
                   Validation
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
           AWS AMI          IBM Custom Image
```

## Commands

```shell
# Check version
packer version

# Format HCL
packer fmt .

# Initialize/download plugins
packer init .

# Upgrade plugins according to constraints
packer init -upgrade .

# Inspect template
packer inspect .

# Validate
packer validate .

# Validate with environment variables
packer validate -var-file="dev.pkrvars.hcl" .

# Build
packer build .

# Build with var file
packer build -var-file="dev.pkrvars.hcl" .

# Override a variable
packer build \
  -var-file="dev.pkrvars.hcl" \
  -var="environment=test" \
  .

# Debug
packer build -debug \
  -var-file="dev.pkrvars.hcl" .

# Keep control when failure occurs
packer build -on-error=ask \
  -var-file="dev.pkrvars.hcl" .

# Enable logs
export PACKER_LOG=1
export PACKER_LOG_PATH="packer-debug.log"

# Show installed plugins
packer plugins installed

# Install/update required plugins
packer init -upgrade .
```

## Provisioners

  Provisioner         Runs Where       Usage
  ------------------- ---------------- -----------------------------------------
  `shell`             Target VM        Install packages, configure, validate
  `file`              Host → Target    Copy configs/scripts/files
  `ansible`           Packer host      Configure target using Ansible over SSH
  `ansible-local`     Target VM        Run Ansible inside target
  `shell-local`       Packer host      Run local scripts/commands
  `powershell`        Windows target   PowerShell configuration
  `windows-shell`     Windows target   CMD commands
  `windows-restart`   Windows target   Restart and continue build
  `breakpoint`        Build flow       Pause for debugging

### Shell

``` hcl
provisioner "shell" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y nginx git"
  ]
}
```

### File

``` hcl
provisioner "file" {
  source      = "files/nginx.conf"
  destination = "/tmp/nginx.conf"
}
```

### Ansible

``` hcl
provisioner "ansible" {
  playbook_file = "ansible/playbook.yml"
}
```

**Difference:**

``` text
ansible       : Packer Host → SSH → Target VM
ansible-local : Ansible runs inside Target VM
shell         : Command runs inside Target VM
shell-local   : Command runs on Packer Host
```





# Real World Example

[root@anand-vsi-dnd Packer]# cat ibm-golden-image.pkr.hcl 
# ============================================================
# PACKER CONFIGURATION
# ============================================================

packer {
  required_version = ">= 1.7.0"

  required_plugins {

    ibmcloud = {
      version = ">= 3.0.0"
      source  = "github.com/IBM/ibmcloud"
    }

    ansible = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/ansible"
    }

  }
}

# ============================================================
# VARIABLES
# Values that change between environments
# ============================================================

variable "ibm_api_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "us-south"
}

variable "subnet_id" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "security_group_id" {
  type    = string
  default = ""
}

variable "base_image_name" {
  type = string

  # Replace with a currently available IBM Cloud Ubuntu image.
  default = "ibm-ubuntu-24-04-4-minimal-amd64-7"
}

variable "vsi_profile" {
  type    = string
  default = "bx2-2x8"
}

variable "environment" {
  type    = string
  default = "dev"
}


# ============================================================
# LOCALS
# Values calculated internally by Packer
# ============================================================

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  image_name = "golden-ubuntu-${var.environment}-${local.timestamp}"
}


# ============================================================
# DATA
# ============================================================
#
# Intentionally no IBM Cloud data{} block here.
#
# Packer data sources are plugin-specific. The current IBM
# Cloud Packer plugin documents the ibmcloud-vpc builder but
# does not document an IBM Cloud Packer data source that we
# should invent here.
#
# Existing IBM Cloud values such as subnet ID and resource
# group ID are therefore supplied through variables.
# ============================================================


# ============================================================
# SOURCE / BUILDER
#
# Tells Packer HOW and WHERE to build the image.
# ============================================================

source "ibmcloud-vpc" "ubuntu" {

  # Authentication
  api_key = var.ibm_api_key

  # IBM Cloud location
  region = var.region

  # Existing IBM Cloud networking
  subnet_id         = var.subnet_id
  resource_group_id = var.resource_group_id
  security_group_id = var.security_group_id

  # Base operating system
  vsi_base_image_name = var.base_image_name

  # Temporary VSI configuration
  vsi_profile   = var.vsi_profile
  vsi_interface = "public"

  # Name of final custom image
  image_name = local.image_name

  # ----------------------------------------------------------
  # COMMUNICATOR
  #
  # Packer connects to temporary Linux VSI using SSH.
  # ----------------------------------------------------------

  communicator = "ssh"

  ssh_username = "ubuntu"
  ssh_port     = 22
  ssh_timeout  = "15m"

  # IBM builder timeout
  timeout = "30m"

  # IBM plugin-level logging
  logging = "debug"

  # Very useful if Packer crashes unexpectedly.
  # IBM plugin records created resource IDs here.
  resource_track_file = "packer-resources.json"
}


# ============================================================
# BUILD
# ============================================================

build {

  name = "ibm-ubuntu-golden-image"

  sources = [
    "source.ibmcloud-vpc.ubuntu"
  ]


  # ==========================================================
  # PROVISIONER 1 - SHELL
  #
  # Runs INSIDE the temporary IBM Cloud VSI.
  # ==========================================================

  provisioner "shell" {

    inline = [
      "echo '=========================================='",
      "echo 'Starting base package installation'",
      "echo '=========================================='",

      "sudo apt-get update",

      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tree",

      "sudo systemctl enable nginx",

      "echo 'Base package installation completed'"
    ]
  }


  # ==========================================================
  # PROVISIONER 2 - FILE
  #
  # Copies our Nginx configuration from Packer host
  # to temporary IBM Cloud VSI.
  # ==========================================================

  provisioner "file" {

    source      = "files/nginx.conf"
    destination = "/tmp/nginx.conf"
  }


  # ==========================================================
  # PROVISIONER 3 - SHELL
  #
  # Install the uploaded Nginx configuration.
  # ==========================================================

  provisioner "shell" {

    inline = [
      "echo 'Installing custom Nginx configuration'",

      "sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf",

      "sudo nginx -t",

      "sudo systemctl restart nginx",

      "echo 'Nginx configuration completed'"
    ]
  }


  # ==========================================================
  # PROVISIONER 4 - ANSIBLE
  #
  # Ansible runs from the machine executing Packer and
  # configures the temporary IBM Cloud VSI through SSH.
  # ==========================================================

  provisioner "ansible" {

    playbook_file = "ansible/playbook.yml"

    extra_arguments = [
      "--extra-vars",
      "environment=${var.environment}"
    ]
  }


  # ==========================================================
  # PROVISIONER 5 - VALIDATION
  #
  # Never create a golden image without validating it.
  # If any command exits non-zero, the build fails.
  # ==========================================================

  provisioner "shell" {

    inline = [
      "echo '=========================================='",
      "echo 'Validating Golden Image'",
      "echo '=========================================='",

      "nginx -v",
      "git --version",
      "tree --version",

      "nginx -t",

      "sudo systemctl is-enabled nginx",

      "sudo systemctl restart nginx",

      "sudo systemctl is-active --quiet nginx",

      "curl --fail http://localhost",

      "echo '=========================================='",
      "echo 'Golden Image validation successful'",
      "echo '=========================================='"
    ]
  }


  # ==========================================================
  # POST-PROCESSOR
  #
  # Runs against build output/artifact information.
  # ==========================================================

  post-processor "manifest" {

    output     = "packer-manifest.json"
    strip_path = true

    custom_data = {
      environment = var.environment
      image_name  = local.image_name
      created_by  = "packer"
    }
  }
}
[root@anand-vsi-dnd Packer]# 

[root@anand-vsi-dnd Packer]# ls -ltr
total 16
drwxr-xr-x. 2 root root   24 Sep 15 12:12 files
-rw-r--r--. 1 root root  279 Sep 15 12:24 dev.pkrvars.hcl
drwxr-xr-x. 2 root root   26 Sep 15 12:39 ansible
-rw-r--r--. 1 root root 6886 Sep 15 12:40 ibm-golden-image.pkr.hcl
-rw-r--r--. 1 root root  633 Sep 15 12:41 packer-resources.json
[root@anand-vsi-dnd Packer]# 

[root@anand-vsi-dnd Packer]# cat files/nginx.conf 
events {
    worker_connections 1024;
}

http {

    server {

        listen 80;
        server_name _;

        location / {
            return 200 "IBM Cloud Golden Image - Nginx is running\n";
        }
    }
}
[root@anand-vsi-dnd Packer]# cat ansible/playbook.yml 
---
- name: Configure IBM Cloud Golden Image
  hosts: all
  become: true
  gather_facts: true

  tasks:

    - name: Create application directory
      ansible.builtin.file:
        path: /opt/company
        state: directory
        owner: root
        group: root
        mode: "0755"

    - name: Create image information file
      ansible.builtin.copy:
        dest: /opt/company/image-info.txt
        content: |
          Image created using Packer
          Environment: {{ environment }}
        owner: root
        group: root
        mode: "0644"

    - name: Ensure nginx is enabled
      ansible.builtin.service:
        name: nginx
        enabled: true
[root@anand-vsi-dnd Packer]# 