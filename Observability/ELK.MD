# Pre-Requirement Setup

```shell
sudo dnf update -y

sudo dnf install -y \
    curl \
    wget \
    vim \
    unzip \
    tar \
    net-tools \
    lsof \
    firewalld

# Configure Elasticsearch kernel requirement

sudo vi /etc/sysctl.d/99-elasticsearch.conf
# Insert Below
vm.max_map_count=1048576
# Refresh 
sudo sysctl --system

```

