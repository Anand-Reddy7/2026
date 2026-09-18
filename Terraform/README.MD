# Terraform 

# Core Terraform commands

```shell
| Command               | Purpose                                                        |
| --------------------- | -------------------------------------------------------------- |
| `terraform init`      | Initialize directory, providers, modules, backend              |
| `terraform fmt`       | Format `.tf` files                                             |
| `terraform validate`  | Validate Terraform configuration                               |
| `terraform plan`      | Preview infrastructure changes                                 |
| `terraform apply`     | Apply infrastructure changes                                   |
| `terraform destroy`   | Destroy Terraform-managed infrastructure                       |
| `terraform show`      | Display plan/state information                                 |
| `terraform output`    | Display output values                                          |
| `terraform state`     | Inspect/manipulate Terraform state                             |
| `terraform import`    | Bring existing infrastructure under Terraform management       |
| `terraform refresh`   | Refresh state; less commonly used directly in modern workflows |
| `terraform console`   | Interactive console for testing Terraform expressions          |
| `terraform providers` | Show providers used                                            |
| `terraform version`   | Show Terraform version                                         |
```

# Variables
```shell
########################################################
# 1. STRING
# Validation: allowed values using contains()
########################################################

variable "lsf_version" {
  type        = string
  default     = "fixpack_15"
  description = "LSF version"

  validation {
    condition = contains(
      ["fixpack_15", "fixpack_16"],
      var.lsf_version
    )
    error_message = "LSF version must be fixpack_15 or fixpack_16."
  }
}

# Access:
# var.lsf_version


########################################################
# 2. STRING - SENSITIVE
# Validation: cannot be empty
########################################################

variable "ibmcloud_api_key" {
  type        = string
  sensitive   = true
  description = "IBM Cloud API key"

  validation {
    condition     = trimspace(var.ibmcloud_api_key) != ""
    error_message = "IBM Cloud API key cannot be empty."
  }
}

# Access:
# var.ibmcloud_api_key


########################################################
# 3. NUMBER
# Validation: range
########################################################

variable "mtu_value" {
  type        = number
  default     = 9000
  description = "MTU value"

  validation {
    condition = (
      var.mtu_value >= 1500 &&
      var.mtu_value <= 9000
    )
    error_message = "MTU must be between 1500 and 9000."
  }
}

# Access:
# var.mtu_value


########################################################
# 4. BOOLEAN
########################################################

variable "enable_ldap" {
  type        = bool
  default     = false
  description = "Enable or disable LDAP"
}

# No validation normally required.
# Terraform itself accepts only true/false.

# Access:
# var.enable_ldap


########################################################
# 5. LIST OF STRINGS
# Validation: list length
########################################################

variable "zones" {
  type        = list(string)
  default     = ["us-east-1"]
  description = "IBM Cloud zones"

  validation {
    condition     = length(var.zones) == 1
    error_message = "Only one zone can be provided."
  }
}

# Access:
# var.zones[0]


########################################################
# 6. OBJECT
# Validation: regex against object attribute
########################################################

variable "bastion_instance" {
  type = object({
    image   = string
    profile = string
  })

  default = {
    image   = "ibm-ubuntu-22-04"
    profile = "cx2-4x8"
  }

  validation {
    condition = can(
      regex("^ibm-ubuntu", var.bastion_instance.image)
    )
    error_message = "Bastion image must be an IBM Ubuntu image."
  }

  validation {
    condition = can(
      regex("^[^\\s]+-[0-9]+x[0-9]+", var.bastion_instance.profile)
    )
    error_message = "Invalid VSI profile."
  }
}

# Access:
# var.bastion_instance.image
# var.bastion_instance.profile


########################################################
# 7. LIST OF OBJECTS
# Validation: validate every object using alltrue()
########################################################

variable "management_instances" {
  type = list(object({
    profile = string
    count   = number
    image   = string
  }))

  default = [
    {
      profile = "bx2-16x64"
      count   = 2
      image   = "lsf-image"
    }
  ]

  # Every instance count must be > 0
  validation {
    condition = alltrue([
      for inst in var.management_instances :
      inst.count > 0
    ])

    error_message = "Every instance count must be greater than 0."
  }

  # Total management nodes cannot exceed 10
  validation {
    condition = sum([
      for inst in var.management_instances :
      inst.count
    ]) <= 10

    error_message = "Total management node count cannot exceed 10."
  }
}

# Access:
# var.management_instances[0].profile
# var.management_instances[0].count
# var.management_instances[0].image


########################################################
# 8. OPTIONAL NESTED OBJECT
# Validation: handle null first
########################################################

variable "login_instance" {
  type = list(object({
    profile = string
    image   = string

    boot_volume = optional(object({
      profile   = optional(string)
      size      = optional(number)
      iops      = optional(number)
      bandwidth = optional(number)
    }))
  }))

  default = [
    {
      profile = "bx2-2x8"
      image   = "lsf-image"

      boot_volume = {
        profile = "general-purpose"
        size    = 100
      }
    }
  ]

  validation {
    condition = alltrue([
      for inst in var.login_instance :

      inst.boot_volume == null ||
      contains(
        ["sdp", "general-purpose"],
        inst.boot_volume.profile
      )
    ])

    error_message = "Boot volume profile must be sdp or general-purpose."
  }
}

# Access:
# var.login_instance[0].profile
# var.login_instance[0].boot_volume
# var.login_instance[0].boot_volume.size


########################################################
# 9. MAP
# Validation: check map values
########################################################

variable "profiles" {
  type = map(string)

  default = {
    dev   = "small"
    stage = "medium"
    prod  = "large"
  }

  validation {
    condition = alltrue([
      for profile in values(var.profiles) :
      contains(["small", "medium", "large"], profile)
    ])

    error_message = "Profile must be small, medium or large."
  }
}

# Access:
# var.profiles["dev"]
# var.profiles.dev


########################################################
# 10. NULLABLE
########################################################

variable "enable_cspm" {
  type        = bool
  default     = true
  nullable    = false
  description = "Enable CSPM"
}

# nullable = false means caller cannot explicitly provide null.

# Access:
# var.enable_cspm


########################################################
# 11. CONDITIONAL VALIDATION
# Validate B depending on A
########################################################

variable "ldap_server" {
  type    = string
  default = null

  validation {
    condition = (
      var.enable_ldap == false ||
      var.ldap_server == null ||
      trimspace(var.ldap_server) != ""
    )

    error_message = "LDAP server cannot be empty when LDAP is enabled."
  }
}

# Access:
# var.ldap_server


########################################################
# 12. COMPLEX OBJECT + SENSITIVE + NULL
########################################################

variable "cos_credentials" {
  type = object({
    bucket = string
    region = string
    akey   = string
    skey   = string
  })

  sensitive = true
  default   = null

  validation {
    condition = (
      var.cos_credentials == null ||
      (
        trimspace(var.cos_credentials.bucket) != "" &&
        trimspace(var.cos_credentials.region) != "" &&
        trimspace(var.cos_credentials.akey) != "" &&
        trimspace(var.cos_credentials.skey) != ""
      )
    )

    error_message = "When COS credentials are provided, all fields are required."
  }
}

# Access:
# var.cos_credentials.bucket
# var.cos_credentials.region
```

# Terraform Import — Short Notes

Purpose: Bring an existing cloud resource under Terraform management.

```shell
terraform import <terraform-address> <resource-id>
```

Example:

```
terraform import ibm_is_vpc.main <vpc-id>
```

Flow:

```
Existing Resource
      ↓
terraform import
      ↓
Terraform State
      ↓
terraform plan
```

Import does not create the resource. It connects the existing resource to Terraform state.

```
Modern Import
import {
  to = ibm_is_vpc.main
  id = "<vpc-id>"
}
```

Remember :
```shell
resource → CREATE/MANAGE
data     → READ existing resource
import   → MANAGE existing resource
```

After import, always run:

```
terraform plan
```

# TERRAFORM STATE

terraform.tfstate
= Terraform's record/mapping of managed infrastructure.

.tf files → Desired configuration
State     → What Terraform tracks
Cloud     → Actual infrastructure

terraform plan
→ compares/evaluates these to determine changes.

Local State:
terraform.tfstate on local machine.

Remote State:
Shared backend for team/CI workflows.

State Locking:
Prevents concurrent state modification.

Commands:
terraform state list
terraform state show
terraform state mv
terraform state rm
terraform state pull

Important:
- Never casually edit state manually.
- Protect state because it may contain secrets.
- Production normally uses remote state.
- terraform import adds an existing resource to state.

## State Locking - Backend

```shell
terraform {
  backend "s3" {
    endpoint                    = "https://s3.${var.terraform_state_bucket_region}.cloud-object-storage.appdomain.cloud"
    bucket                      = "${var.terraform_state_bucket}"
    key                         = "${var.cluster_prefix}/${var.state_file_key}"
    region                      = "${var.terraform_state_bucket_region}"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    force_path_style            = true

    use_lockfile                = true // It will create a .tflock file 
  }
}

# Unlock the Locking machanism
terraform force-unlock -force 9db590f1-b6fe-c5f2-2678-8804f089deba
terraform plan -lock=false ...

```

# Terraform Taint and Un-Taint

A tainted resource is a resource that is forced to be destroyed and recreated on the next apply command. When a resource is marked as tainted, the state files are updated, but nothing changes on infrastructure. The terraform plan out shows that help will get destroyed and recreated. The changes get implemented when the next apply happens.

If you manually mark a terraform resource as Tainted, It will force to detsroy / recreate on the next plan/apply by using CLI.

```shell
Terraform taint resource.name

Terraform untaint resource.name
```

# How to create a specific resource out of lots of resouces in a file.

```shell

    terraform apply -target=aws_vpc.myvpc -target=aws_s3_bucker.mybucket
    
- If you want to create a specific module code then do like below.
    
    terraform apply -target=module.instance
    
- Destroy a specific resource
    
    terraform destroy -target=aws_vpc.myvpc
```


# Terraform WorkSpace

```shell
    In Terraform CLI, workspaces are separate instances of state data that can be used from the same working directory. You can use workspaces to manage multiple non-overlapping groups of resources with the same configuration.

    Note: If you are using the backend, then fro every workspace it will have separete folder in S3 backend to store the config files.
    
            terraform workspace list
            terraform workspace new dev
            terraform workspace select dev
            terraform workspace delete dev
            
    Example : 
    
            terraform apply -var-files "filename" or -var "prefix=variables"
            
    Example :           
    
            locals {
                env="${terraform.workspace}"
```

# Terraform provisioners

A provisioner lets Terraform execute an action/script as part of a resource lifecycle.

```
local-exec   → run command on Terraform machine
remote-exec  → run command on remote server
file         → copy file/directory to remote server
```

## remote-exec example

```shell
resource "null_resource" "configure_server" {

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = "vpcuser"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}
```

# TERRAFORM LIFECYCLE

```shell
lifecycle {
   ...
}

1. create_before_destroy
→ Create NEW first
→ Destroy OLD afterward
→ Helps reduce downtime.

2. prevent_destroy
→ Prevent Terraform from destroying
  important resource.

3. ignore_changes
→ Ignore changes to selected attributes.
→ Useful when another system manages them.

4. replace_triggered_by
→ Replace this resource when specified
  managed resource/attribute changes.

Remember:

depends_on
→ controls dependency/order

lifecycle
→ controls create/update/replace/destroy behavior
```