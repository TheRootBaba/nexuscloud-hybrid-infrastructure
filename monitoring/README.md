# Infrastructure Monitoring

Use Prometheus, Grafana OSS, and Node Exporter. Begin with one Ubuntu target.

Install Node Exporter using official guidance: https://github.com/prometheus/node_exporter. On Ubuntu package repositories where available:
```bash
sudo apt update
sudo apt install -y prometheus-node-exporter
sudo systemctl enable --now prometheus-node-exporter
```
Node Exporter listens on TCP 9100 by default. Allow this port only from the Prometheus server.

Copy prometheus/prometheus.yml into your Prometheus configuration and replace example targets with reachable host IPs. Install Grafana OSS from https://grafana.com/docs/grafana/latest/setup-grafana/installation/. Add Prometheus as a data source. Keep monitoring ports private; change default credentials.
