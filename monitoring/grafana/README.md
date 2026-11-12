# Grafana Dashboard Notes

Add Prometheus as a data source. Suggested panels:

CPU utilization:
`100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`

Memory used percentage:
`(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100`

Root filesystem used percentage:
`100 * (1 - node_filesystem_avail_bytes{mountpoint="/",fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{mountpoint="/",fstype!~"tmpfs|overlay"})`

Network receive/transmit:
`rate(node_network_receive_bytes_total[5m])`
`rate(node_network_transmit_bytes_total[5m])`

Label units clearly and keep the dashboard private to the management network.
