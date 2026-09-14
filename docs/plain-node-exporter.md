# Plain node_exporter compatibility

Start with **HPC / Node Exporter Fleet (Start Here)**. It queries standard
`node_*` metrics directly and requires neither recording rules nor custom target
labels.

The `Hostname / instance regex` field matches Prometheus's `instance` label.
Prometheus regex matchers are fully anchored. Examples:

| Instances | Regex |
|---|---|
| `cn0001:9100` through `cn9999:9100` | `cn[0-9]{4}(:9100)?` |
| FQDN compute nodes | `cn[0-9]{4}\\.example\\.org:9100` |
| `compute-001` through `compute-999` | `compute-[0-9]{3}(:9100)?` |
| Any host containing `cn` | `.*cn.*` |

The `Prometheus job regex` defaults to `.*`. Once data appears, restrict it to
the actual scrape job shown by this diagnostic query:

```promql
count by (job) (node_uname_info)
```

Use these checks in Grafana Explore before troubleshooting a dashboard:

```promql
count by (job) (node_uname_info)
count by (job, instance) (node_cpu_seconds_total{mode="idle"})
node_memory_MemTotal_bytes
node_hwmon_temp_celsius
```

If the first three return data and `node_hwmon_temp_celsius` does not, the
dashboard is working but the host is not exposing supported hwmon sensors to
node_exporter. Confirm `/sys/class/hwmon` visibility and collector success:

```promql
node_scrape_collector_success{collector="hwmon"}
```

## Advanced dashboards

Dashboards that query `hpc:*` require `prometheus/rules/*.yml` to be loaded by
the metrics backend. The rules now preserve the standard `instance` label and do
not assume that the scrape job is literally named `node-exporter`. Custom
`cluster`, `partition`, `rack`, `node`, and `node_profile` labels remain optional
enhancements for the topology-aware views.

## Slurm grid

**HPC / Slurm Node Cell Grid (Start Here)** follows the same compatibility
pattern. It queries `slurm_node_info` directly and filters the Slurm `node` label
with a textbox regex. Its default is `cn[0-9]{4}`; unlike node_exporter's
`instance`, a Slurm node name normally has no `:9100` suffix. The grid does not
require the optional `hpc:slurm_node_state:code` recording rule.
