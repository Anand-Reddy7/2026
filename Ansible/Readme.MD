## What is Ansible?

Ansible is an open-source automation and configuration-management tool used to automate tasks across servers.

Instead of manually logging into 100 servers and doing the same work, you write it once in Ansible and execute it across all servers.

### Uses:

```
Configuration management
Server automation
Application deployment
Package management
Service management
```

|                           | **Ansible**   | **Chef**          | **Puppet**        |
| ------------------------- | ------------- | ----------------- | ----------------- |
| Architecture              | Agentless     | Agent-based       | Agent-based       |
| Communication             | SSH / WinRM   | Chef Client       | Puppet Agent      |
| Language                  | YAML + Jinja2 | Ruby DSL          | Puppet DSL        |
| Control model             | Push          | Mostly pull       | Mostly pull       |
| Agent required?           | ❌ No          | ✅ Yes             | ✅ Yes             |
| Learning curve            | ⭐ Easy        | ⭐⭐⭐ Harder        | ⭐⭐⭐               |
| Configuration             | Playbooks     | Cookbooks/Recipes | Manifests/Modules |
| Popular for DevOps        | ⭐⭐⭐⭐⭐         | ⭐⭐                | ⭐⭐⭐               |
| Good for cloud automation | ⭐⭐⭐⭐⭐         | ⭐⭐⭐               | ⭐⭐⭐               |


### What is the difference between Ansible, Puppet and Chef?

```
All three are configuration-management and automation tools. Ansible is agentless and generally uses SSH with a push model, while Puppet and Chef traditionally use agents installed on managed nodes and follow a pull-oriented model. Ansible uses YAML-based playbooks, whereas Puppet and Chef use their own DSLs, with Chef heavily based on Ruby.
```
### Idempotency means

```
Idempotency means: Running the same automation multiple times gives the same final result without making unnecessary changes.
```

### Which one better b/w these 3 ??

```
I would prefer Ansible over Chef and Puppet for most modern DevOps environments, mainly because it is agentless, uses SSH, has a simple YAML-based syntax, and integrates very well with CI/CD and cloud automation. It also has good idempotency and is easy to start with and maintain. Chef and Puppet are also capable configuration-management tools, but their agent-based architecture and steeper learning curve can make Ansible simpler for many environments.

The choice depends on the environment, but for a new DevOps/cloud automation setup, I would generally choose Ansible because of its agentless architecture, simplicity, YAML playbooks, and strong integration with CI/CD and cloud tooling.
```

## Initial Setup

- Create a new user in all the nodes

- Create a SSH keys into the Management node and copy the .pub into all the worker nodes

- Update the .cfg file with below

```
[defaults]

inventory = ./inventory

remote_user = lsfadmin

private_key_file = ~/.ssh/ansible_key

host_key_checking = True

become = True
become_method = sudo
become_user = root

forks = 10

timeout = 30

log_path = /var/log/ansible.log

roles_path = ./roles
```


## Inventory
```
[lsfadmin@anand-vsi-dnd ansible]$ ansible-inventory --graph
@all:
  |--@servers:
  |  |--@redhat_servers:
  |  |  |--10.244.0.4
  |  |--@ubuntu_servers:
  |  |  |--10.244.0.6
  |--@ungrouped:


[lsfadmin@anand-vsi-dnd ansible]$ ansible-inventory --list
{
    "_meta": {
        "hostvars": {}
    },
    "all": {
        "children": [
            "servers",
            "ungrouped"
        ]
    },
    "redhat_servers": {
        "hosts": [
            "10.244.0.4"
        ]
    },
    "servers": {
        "children": [
            "redhat_servers",
            "ubuntu_servers"
        ]
    },
    "ubuntu_servers": {
        "hosts": [
            "10.244.0.6"
        ]
    }
}
[lsfadmin@anand-vsi-dnd ansible]$ 
```


```
[webservers]
10.10.10.10
10.10.10.11

[webservers:vars]
ansible_user=lsfadmin

[appservers]
10.10.10.20
10.10.10.21
10.10.10.22
10.10.10.23

[dbservers]
db01 ansible_host=10.10.10.30 ansible_user=dbuser ## Host aliases (db01 → 10.10.10.30) 
db02 ansible_host=10.10.10.31 ansible_user=dbuser

[production:children]
webservers
appservers
```

### Run Playbook on Multiple Inventories
```
ansible-playbook get_logs.yml -i staging -i production
```

### Common Host Variables
```
web01 ansible_host=10.10.10.10
      ansible_user=lsfadmin
      ansible_port=22
      ansible_ssh_private_key_file=~/.ssh/ansible_key
```

### Limitations of Inventory

- Specific group --> ansible webservers -m ping

- Multiple groups --> ansible webservers:appservers -m ping ( webservers OR appservers )

- Intersection --> ansible webservers:&production -m ping  ( Hosts that belong to both groups)

- Exclusion --> ansible all:!dbservers -m ping ( Everything except database servers. )

## Ansible Adhoc Mode

An ad-hoc command is a one-time Ansible command used to perform a task without creating a playbook.

Syntax:

```
ansible  all  -m command  -a "hostname"  -o
          │       │            │           │
          │       │            │           └─ -o --> Output format
          │       │            └────────────── -a --> Arguments
          │       └────────────────────────── -m --> Module
          └────────────────────────────────── Target hosts
```

```
Ansible { group name/server name }  - I { inventory/host name } –m { module } 
Ex:  ansible web -i inventory -m ping


Ansible { group name/server name }  - I { inventory/host name } –m { module } -a {specify what you want}
Ex:  ansible web -i inventory -m yum -a "name=httpd state=latest" -b
note :  -b for become root user
```


## Ansible Playbooks

An Ansible Playbook is a YAML file that defines a set of tasks Ansible should perform on one or more managed servers.

It is used to automate server configuration, application deployment, software installation, and other repeatable tasks.

Playbooks are declarative and idempotent, meaning you define the desired state and Ansible makes changes only when required.

```
ansible-playbook <playbook.yml>
ansible-playbook <playbook.yml> -vvv
ansible-playbook <playbook.yml> --syntax-check
ansible-playbook <playbook.yml> --check
ansible-playbook <playbook.yml> --diff             ## Show configuration differences
ansible-playbook <playbook.yml> --limit <server>   ## Run against specific host/group
```


---
- name: Install and Configure Nginx
  hosts: redhat_servers
  become: true

  vars:
    packages:
      - tree
      - unzip

  tasks:

    - name: Package install
      ansible.builtin.dnf:
        name: "{{ packages }}"
        state: present

    - name: Create multiple Users
      ansible.builtin.user:
        name: "{{ item }}"
        state: present
      loop:  # with_items also same as loop
        - user1
        - user2
      tags:
        - create_users

    - name: Nginx | Deployment
      block:

        - name: Nginx | Install Nginx
          ansible.builtin.dnf:
            name: nginx
            state: present

        - name: Nginx | Get Nginx version
          ansible.builtin.command:
            cmd: nginx -v
          register: nginx_output
          changed_when: false

        - name: Nginx | Display Nginx version
          ansible.builtin.debug:
            var: nginx_output.stderr #msg: {{ nginx_output.stderr }} also works

        - name: Nginx | Copy index.html to the destination
          ansible.builtin.copy:
            src: /etc/ansible/index.html
            dest: /usr/share/nginx/html/
          notify: Restart Nginx

        - name: Nginx | Check the Application Availability
          ansible.builtin.command:
            cmd: curl -s http://localhost
          register: application_health
          changed_when: false

        - name: Health check
          ansible.builtin.uri:
            url: http://localhost:8080/health
            status_code: 200
        
          until: application_health.rc == 0
          retries: 10
          delay: 5


      when: ansible_distribution == "RedHat" or ansible_distribution == "CentOS"

      rescue:

        - name: Nginx | Deployment Failed
          ansible.builtin.debug:
            msg: "Nginx Deployment Failed on {{ inventory_hostname }}"

      always:

        - name: Nginx | Deployment Completed
          ansible.builtin.debug:
            msg: "Nginx Deployment block completed on {{ inventory_hostname }}"

  handlers:

    - name: Restart Nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
        enabled: true


# Extra Vars
ansible-playbook extra_vars.yml --extra-vars "package=wget"

# Run the playbook with only specific Tag
ansible-playbook extra_vars.yml --tags "create_users"
ansible-playbook extra_vars.yml --skip-tags "create_users,another_tag"

## Variable precedence

```
Role defaults
      ↓
group_vars
      ↓
host_vars
      ↓
play/task variables
      ↓
-e / extra vars
      ↓
    WIN 🏆
```

## until / retries

```
- name: Check application
  ansible.builtin.command:
    cmd: curl http://localhost:8080
  register: result

  until: result.rc == 0
  retries: 10
  delay: 5
```

Note:

```
rc = 0     → command succeeded ✅
rc != 0    → command failed ❌
```

## set_fact

set_fact allows you to create or change a variable dynamically while the playbook is running.

```
- name: Nginx | Get version
  ansible.builtin.command:
    cmd: nginx -v
  register: nginx_output
  changed_when: false

- name: Nginx | Set version fact
  ansible.builtin.set_fact:
    nginx_version: "{{ nginx_output.stderr }}"

- name: Nginx | Display version
  ansible.builtin.debug:
    msg: "Installed Nginx version: {{ nginx_version }}"
```


## Templates — Jinja2

```
## Create a file "nginx.conf.j2"

server {
    listen {{ nginx_port }};

    server_name {{ ansible_hostname }};

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}


- name: Configure Nginx
  hosts: redhat_servers
  become: true

  vars:
    nginx_port: 8080

  tasks:

    - name: Deploy Nginx configuration
      ansible.builtin.template:
        src: nginx.conf.j2
        dest: /etc/nginx/conf.d/myapp.conf
```

## Ansible Vault

Ansible Vault encrypts sensitive data so you don't have to store passwords and secrets in plain text.

```
create   → Create encrypted file
view     → Read encrypted file
edit     → Modify encrypted file
encrypt  → Encrypt existing file
decrypt  → Convert to plaintext
rekey    → Change Vault password
```

```
ansible-vault create secrets.yml
ansible-vault view secrets.yml
ansible-vault edit secrets.yml
ansible-vault encrypt secrets.yml
ansible-vault decrypt secrets.yml
ansible-vault rekey secrets.yml # Change the encryption password
```

Note: Get the password details to variable by running like below 

```
ansible-playbook nginx.yml --ask-vault-pass
```

## Ansible Built-in Modules

A module is basically the unit that performs an operation on the managed server.

### ansible.builtin Modules

ansible.builtin modules are modules that are part of Ansible itself.
```
ansible.builtin.dnf
ansible.builtin.user
ansible.builtin.copy
ansible.builtin.service
ansible.builtin.command
ansible.builtin.debug
ansible.builtin.template
ansible.builtin.file
ansible.builtin.package
```

### What are "other" modules?

There are modules that come from Ansible Collections maintained by:

```
Ansible community
Red Hat
Cloud providers
Vendors
Other organizations
```

For example:

```
amazon.aws.ec2_instance
community.general.snap 
community.general.timezone
community.docker
```

### Example

1. On the Controller Node - Install the AWS Ansible collection
```
# Install
ansible-galaxy collection install amazon.aws

# verify
ansible-galaxy collection list
```


2. Install boto3 and botocore

3. Configure AWS credentials
```
aws configure
```

4. Your first EC2 playbook

```
---
- name: Create EC2 Instance
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    aws_region: ap-south-1
    ami_id: ami-xxxxxxxxxxxxxxxxx
    instance_type: t3.micro
    key_name: ansible-key
    subnet_id: subnet-xxxxxxxxxxxxxxxxx
    security_group_id: sg-xxxxxxxxxxxxxxxxx

  tasks:

    - name: Create EC2 instance
      amazon.aws.ec2_instance:
        name: ansible-demo-server
        image_id: "{{ ami_id }}"
        instance_type: "{{ instance_type }}"
        region: "{{ aws_region }}"
        key_name: "{{ key_name }}"
        vpc_subnet_id: "{{ subnet_id }}"
        security_group: "{{ security_group_id }}"
        wait: true
        tags:
          Environment: Dev
          Application: Ansible
          ManagedBy: Ansible
      register: ec2_result

    - name: Display EC2 result
      ansible.builtin.debug:
        var: ec2_result
```

### 
```
---
- name: Configure Server Timezone
  hosts: redhat_servers
  become: true

  tasks:

    - name: Set timezone to Asia/Kolkata
      community.general.timezone:
        name: Asia/Kolkata
```


## Ansible Galaxy?

Ansible Galaxy is a public repository/platform where you can find, download, share, and install Ansible Roles and Collections.

```
Ansible Galaxy
      |
      +-- Roles
      |
      +-- Collections
      |
      +-- Community automation
```
Instead of writing everything yourself, you can reuse automation that others have already created.

```
# Create your own role
ansible-galaxy role init nginx

# Search roles
ansible-galaxy role search nginx

# Install a role
ansible-galaxy role install <role-name>

# Install a collection
ansible-galaxy collection install amazon.aws

# Install project dependencies
ansible-galaxy install -r requirements.yml
```

## Ansible Roles

In Ansible, the role is the primary mechanism for breaking a playbook into multiple files. This simplifies writing complex playbooks, and it makes them easier to reuse. The breaking of playbook allows you to logically break the playbook into reusable components.

```
nginx/
│
├── tasks/
│   └── main.yml
│
├── handlers/
│   └── main.yml
│
├── templates/
│   └── nginx.conf.j2
│
├── files/
│   └── index.html
│
├── defaults/
│   └── main.yml
│
├── vars/
│   └── main.yml
│
├── meta/
│   └── main.yml
│
└── README.md
```

```
| Directory    | Remember it as                    | Nginx example                     |
| ------------ | --------------------------------- | --------------------------------- |
| `tasks/`     | **DO**                            | Install/configure/start Nginx     |
| `handlers/`  | **REACT**                         | Restart Nginx after config change |
| `templates/` | **DYNAMIC FILES**                 | `nginx.conf.j2`                   |
| `files/`     | **STATIC FILES**                  | `index.html`                      |
| `defaults/`  | **DEFAULT SETTINGS**              | Port `80`                         |
| `vars/`      | **ROLE VARIABLES**                | Package/service names             |
| `meta/`      | **ROLE INFORMATION/DEPENDENCIES** | Depends on `common`               |
| `README.md`  | **DOCUMENTATION**                 | How to use the role               |

```



### Import Tasks
```
# Disable hyperthreading on all cluster nodes
- name: Disable CPU hyperthreading on cluster nodes
  import_tasks: hyperthreading.yml

# Configure App Center (only on GUI hosts with elevated privileges)
- name: Configure App Center on GUI nodes
  block:
    - import_tasks: app_center_configure.yml
  become: true
  become_flags: "-i"
  when:
    - inventory_hostname in groups['gui_hosts']
  rescue:
    - name: Log failure for App Center configuration
      ansible.builtin.debug:
        msg: "WARNING: App Center configuration failed"
```