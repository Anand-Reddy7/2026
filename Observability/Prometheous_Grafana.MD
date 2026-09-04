# Prometheous

Prometheus collects, stores and queries metrics. Prometheus stores below values along with timestamps and labels as time-series data.

- Prometheus is a Pull Model

```text
             Pull metrics
                 ↓
        ┌─────────────────┐
        │   Prometheus    │
        └────────┬────────┘
                 │
       GET /metrics
                 │
        ┌────────▼────────┐
        │ Node Exporter   │
        └────────┬────────┘
                 │
             Linux OS
```

```text
CPU       → 35%
Memory    → 62%
Disk      → 71%
Load      → 2.4
Network   → 150 MB/s
```

# Grafana

Grafana visualizes and presents the metrics collected by Prometheus.

```text
Prometheus
     │
     │ metrics
     ▼
Grafana
     │
     ├── CPU Dashboard
     ├── Memory Dashboard
     ├── Disk Dashboard
     ├── Network Dashboard
     └── Alerts
```

## Metrics Exporter

```text
Linux          → Node Exporter
Windows        → Windows Exporter
MySQL          → MySQL Exporter
PostgreSQL     → PostgreSQL Exporter
HAProxy        → HAProxy Exporter
Blackbox       → Blackbox Exporter
```


# Prometheus Installation

# Prometheus Installation

This guide explains how to install and run Prometheus as a systemd service on a Linux server.

## 1. Create Prometheus User

Create a dedicated, non-login user for Prometheus:

```bash
sudo useradd --no-create-home --shell /sbin/nologin prometheus
```

### Options Explained

- `sudo` — Run the command with root privileges.
- `useradd` — Create a Linux user.
- `--no-create-home` — Do not create a home directory.
- `--shell /sbin/nologin` — Prevent interactive login.
- `prometheus` — Username for the Prometheus service.

---

## 2. Create Prometheus Directories

Create the configuration and data directories:

```bash
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus
```

### Directory Purpose

| Directory | Purpose |
|---|---|
| `/etc/prometheus` | Prometheus configuration files |
| `/var/lib/prometheus` | Prometheus time-series database (TSDB) data |

---

## 3. Set Directory Ownership

Give the Prometheus user ownership of the required directories:

```bash
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

You can also ensure all files under the configuration directory belong to Prometheus:

```bash
sudo chown -R prometheus:prometheus /etc/prometheus
```

---

## 4. Copy Prometheus Configuration

Copy the Prometheus configuration file:

```bash
sudo cp prometheus.yml /etc/prometheus/
```

Then set the correct ownership:

```bash
sudo chown -R prometheus:prometheus /etc/prometheus
```

The main configuration file is:

```text
/etc/prometheus/prometheus.yml
```

---

## 5. Download Prometheus

Move to the temporary directory:

```bash
cd /tmp
```

Download Prometheus:

```bash
wget https://github.com/prometheus/prometheus/releases/download/v3.14.0/prometheus-3.14.0.linux-amd64.tar.gz
```

Extract the archive:

```bash
tar -xvf prometheus-3.14.0.linux-amd64.tar.gz
```

This creates a directory similar to:

```text
prometheus-3.14.0.linux-amd64/
```

---

## 6. Important Prometheus Binaries

There are two important binaries in the extracted Prometheus directory:

### `prometheus`

The main Prometheus monitoring server.

It is responsible for:

- Scraping metrics from targets.
- Storing metrics in the TSDB.
- Evaluating alerting and recording rules.
- Providing the Prometheus web UI.
- Executing PromQL queries.

### `promtool`

A command-line utility used for:

- Configuration validation.
- Rule validation.
- Troubleshooting.
- Checking Prometheus configuration files.

---

## 7. Validate Prometheus Configuration

From the extracted Prometheus directory:

```bash
./promtool check config prometheus.yml
```

Or validate the configuration installed under `/etc/prometheus`:

```bash
sudo ./promtool check config /etc/prometheus/prometheus.yml
```

A successful validation should indicate that the configuration file is valid.

> **Important:** Always validate `prometheus.yml` before starting or restarting Prometheus.

---

## 8. Install Prometheus Binary

Copy the Prometheus binary to `/usr/local/bin`:

```bash
sudo cp prometheus-3.14.0.linux-amd64/prometheus /usr/local/bin/
```

Copy `promtool` as well:

```bash
sudo cp prometheus-3.14.0.linux-amd64/promtool /usr/local/bin/
```

Verify:

```bash
prometheus --version
promtool --version
```

---

## 9. Create Prometheus systemd Service

Create the systemd service file:

```bash
sudo vi /etc/systemd/system/prometheus.service
```

Add the following configuration:

```ini
[Unit]
Description=Prometheus Monitoring Server
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### Important Service Settings

| Setting | Purpose |
|---|---|
| `User=prometheus` | Run Prometheus as the Prometheus user |
| `Group=prometheus` | Run Prometheus using the Prometheus group |
| `ExecStart` | Command used to start Prometheus |
| `--config.file` | Location of Prometheus configuration |
| `--storage.tsdb.path` | Location where metrics are stored |
| `Restart=on-failure` | Restart Prometheus if it fails |

---

## 10. Reload systemd

After creating or modifying the service file:

```bash
sudo systemctl daemon-reload
```

This tells systemd to reload the service definitions.

---

## 11. Enable Prometheus

Enable Prometheus so it starts automatically when the server boots:

```bash
sudo systemctl enable prometheus
```

---

## 12. Start Prometheus

Start the Prometheus service:

```bash
sudo systemctl start prometheus
```

Check the service status:

```bash
sudo systemctl status prometheus
```

> The `systemctl start prometheus` command only needs to be run once. Running it twice is unnecessary.

---

## 13. Check Prometheus Logs

If Prometheus does not start, check the systemd logs:

```bash
sudo journalctl -u prometheus
```

To follow the logs in real time:

```bash
sudo journalctl -u prometheus -f
```

These commands are very useful for troubleshooting configuration or permission problems.

---

## 14. Test Prometheus

Prometheus listens on port `9090` by default.

Test the metrics endpoint:

```bash
curl http://localhost:9090/metrics
```

If Prometheus is running correctly, you should see Prometheus metrics in the response.

You can also check the HTTP status:

```bash
curl -I http://localhost:9090/metrics
```

---

## 15. Verify Prometheus Port

Check whether Prometheus is listening on port `9090`:

```bash
sudo ss -lntp | grep 9090
```

Expected output will show Prometheus listening on:

```text
0.0.0.0:9090
```

or:

```text
127.0.0.1:9090
```

depending on the Prometheus configuration.

---

## 16. Access Prometheus Web UI

From a browser, open:

```text
http://<SERVER-IP>:9090
```

For example:

```text
http://192.168.1.100:9090
```

# Prometheus Installation Flow

```text
Linux Server
     |
     +-- Create prometheus user
     |
     +-- Create directories
     |      |
     |      +-- /etc/prometheus
     |      +-- /var/lib/prometheus
     |
     +-- Download Prometheus
     |
     +-- Install prometheus binary
     |      |
     |      +-- /usr/local/bin/prometheus
     |      +-- /usr/local/bin/promtool
     |
     +-- Configure
     |      |
     |      +-- /etc/prometheus/prometheus.yml
     |
     +-- Validate config
     |      |
     |      +-- promtool check config
     |
     +-- systemd
     |      |
     |      +-- prometheus.service
     |
     +-- Start Prometheus
     |
     +-- Prometheus
            |
            +-- Port 9090
            |
            +-- TSDB
            |     |
            |     +-- /var/lib/prometheus
            |
            +-- Web UI
            |
            +-- /metrics
```

# Quick Verification Checklist

Run these commands after installation:

```bash
# Check Prometheus version
prometheus --version

# Check configuration
sudo promtool check config /etc/prometheus/prometheus.yml

# Check service status
sudo systemctl status prometheus

# Check logs
sudo journalctl -u prometheus -f

# Check port
sudo ss -lntp | grep 9090

# Test Prometheus endpoint
curl http://localhost:9090/metrics
```

## Key Locations

```text
Prometheus binary
    /usr/local/bin/prometheus

Promtool binary
    /usr/local/bin/promtool

Configuration
    /etc/prometheus/prometheus.yml

Data / TSDB
    /var/lib/prometheus

systemd service
    /etc/systemd/system/prometheus.service

Prometheus web port
    9090
```

## Install Node_Exporter 

```shell
sudo useradd \
  --no-create-home \
  --shell /sbin/nologin \
  node_exporter

cd /tmp

wget https://github.com/prometheus/node_exporter/releases/download/v1.12.1/node_exporter-1.12.1.linux-amd64.tar.gz

tar -xvf node_exporter-1.12.1.linux-amd64.tar.gz

cd node_exporter-1.12.1.linux-amd64

sudo cp node_exporter /usr/local/bin/


sudo chown root:root /usr/local/bin/node_exporter
sudo chmod 755 /usr/local/bin/node_exporter


sudo vi /etc/systemd/system/node_exporter.service

[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple

ExecStart=/usr/local/bin/node_exporter

Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter

ps -ef | grep node_exporter
ps -ef | grep node_exporter

# Verify 
curl -s http://localhost:9100/metrics | grep node_cpu
curl -s http://localhost:9100/metrics | grep node_memory
curl -s http://localhost:9100/metrics | grep node_filesystem
```


## Add the Linux server details in the Prometheous cluster'

```shell
- job_name: "linux_nodes"
    static_configs:
      - targets:
          - "162.133.129.130:9100"
        labels:
            hostname: "client01"
            environment: "production"
            role: "web"

# check the config
sudo ./promtool check config /etc/prometheus/prometheus.yml

# Restart the promethoeus
sudo systemctl restart prometheus
```


# Grafana Setup

```shell

cd /tmp
wget -q -O gpg.key https://rpm.grafana.com/gpg.key
sudo rpm --import gpg.key

sudo vi /etc/yum.repos.d/grafana.repo

[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1

sudo dnf repolist

sudo dnf install -y grafana

grafana-server -v


sudo systemctl enable grafana-server
sudo systemctl start grafana-server
sudo systemctl status grafana-server

sudo ss -lntp | grep 3000

```

# Alert Manager

```text
RHEL 8.10 Monitoring Server
┌──────────────────────────────────────────────┐
│                                              │
│  Prometheus :9090                            │
│       │                                      │
│       │ Alerting rules                       │
│       ▼                                      │
│  Alertmanager :9093                          │
│       │                                      │
│       ▼                                      │
│  Email / Slack / Teams                       │
│                                              │
│  Grafana :3000                               │
│       │                                      │
│       ▼                                      │
│  Visualization                               │
└──────────────────────────────────────────────┘
          │
          │ scrape :9100
          ▼
    Linux Client Servers
       Node Exporter
```

```shell
cd /tmp

wget https://github.com/prometheus/alertmanager/releases/download/v0.34.0/alertmanager-0.34.0.linux-amd64.tar.gz
tar -xvf alertmanager-0.34.0.linux-amd64.tar.gz
cd alertmanager-0.34.0.linux-amd64


sudo useradd \
  --no-create-home \
  --shell /sbin/nologin \
  alertmanager

sudo mkdir -p /etc/alertmanager
sudo mkdir -p /var/lib/alertmanager

sudo cp alertmanager /usr/local/bin/
sudo cp amtool /usr/local/bin/

sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool
sudo chown -R alertmanager:alertmanager /etc/alertmanager
sudo chown -R alertmanager:alertmanager /var/lib/alertmanager

sudo vi /etc/alertmanager/alertmanager.yml

global:
  resolve_timeout: 5m

route:
  receiver: "devops-team"

receivers:
  - name: "devops-team"

# Validate 
sudo amtool check-config /etc/alertmanager/alertmanager.yml

# Create a Service
sudo vi /etc/systemd/system/alertmanager.service

[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple

ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager

Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target


sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager
sudo systemctl status alertmanager

# Verify
sudo ss -lntp | grep 9093
```

## Slack request Process

- Open Slack API
- Create a Slack App


## Create Rule 

sudo mkdir -p /etc/prometheus/rules

sudo vi /etc/prometheus/rules/linux-alerts.yml

```
groups:

  - name: linux-server-alerts

    rules:

      - alert: LinuxServerDown

        expr: up{job="linux_nodes"} == 0

        for: 2m

        labels:
          severity: critical

        annotations:
          summary: "Linux server is down"
          description: "{{ $labels.hostname }} ({{ $labels.instance }}) has been down for more than 2 minutes."
```

```
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'instance']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h

  receiver: "devops-slack"

receivers:

  - name: "devops-slack"

    slack_configs:

      - api_url: ""
        channel: "#hpcc-alerting-test"
        send_resolved: true

        title: '{{ if eq .Status "firing" }}🚨 ALERT FIRING{{ else }}✅ ALERT RESOLVED{{ end }}'

        text: |
          *Alert:* {{ .CommonLabels.alertname }}
          *Severity:* {{ .CommonLabels.severity }}
          *Instance:* {{ .CommonLabels.instance }}
          *Hostname:* {{ .CommonLabels.hostname }}

          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
```



