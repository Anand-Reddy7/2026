## Prometheus.yml

```shell
[root@anand-vsi-dnd ~]# cat /etc/prometheus/prometheus.yml 
global:
  scrape_interval: 15s
  evaluation_interval: 15s


rule_files:
  - "/etc/prometheus/rules/*.yml"


alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - "localhost:9093"


scrape_configs:

  - job_name: "prometheus"
    static_configs:
      - targets:
          - "localhost:9090"


  - job_name: "linux_nodes"

    static_configs:

      - targets:
          - "162.133.129.130:9100"
        labels:
          hostname: "client01"
          env: "prod"
          role: "linux"

      - targets:
          - "localhost:9100"
        labels:
          hostname: "client02"
          env: "prod"
          role: "linux"
```

## Alerting Rule
```shell
[root@anand-vsi-dnd ~]# cat /etc/prometheus/rules/linux-alerts.yml 
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

      - alert: HighCPUUsage
        expr: 100 - (avg by (instance, hostname) (rate(node_cpu_seconds_total{job="linux_nodes", mode="idle"}[5m])) * 100) > 75
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "{{ $labels.hostname }} ({{ $labels.instance }}) CPU usage has been above 75% for more than 5 minutes."
```

# Alertmanager.yml
```shell
[root@anand-vsi-dnd ~]# cat /etc/alertmanager/alertmanager.yml 
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
[root@anand-vsi-dnd ~]# 
```