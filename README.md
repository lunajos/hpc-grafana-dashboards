# HPC Grafana dashboards

Dashboard-as-code and Prometheus rules for operating a large Linux HPC fleet.
The design favors fast fleet triage, topology-aware heatmaps, and a linked node
drill-down rather than a single dashboard with thousands of series.

## What operators see

| View | Question it answers | Default time |
|---|---|---|
| Fleet overview | Is the cluster healthy right now? | 15 minutes |
| Thermal topology | Which nodes, racks, or sensors are hot? | 1 hour |
| Storage and fabric | Is NFS, Ethernet, or InfiniBand the bottleneck? | 1 hour |
| Node drill-down | Why is this particular node unhealthy? | 6 hours |
| Capacity and trends | Are thermals, utilization, or errors getting worse? | 30 days |

See [docs/information-architecture.md](docs/information-architecture.md) for the
panel layout and [docs/metrics.md](docs/metrics.md) for exporter coverage.

## Repository layout

```text
dashboards/                         provisioned Grafana dashboard JSON
grafana/provisioning/               datasource and dashboard providers
prometheus/rules/                   recording and alerting rules
prometheus/file_sd/                 example topology-aware targets
docs/                               design, metric, and rollout guidance
examples/                           node_exporter service configuration
```

## Quick start

1. Add stable labels to every scrape target: `cluster`, `partition`, `rack`,
   `chassis`, and `role`. Do not encode these only in hostnames.
2. Deploy node_exporter 1.11.1 (the latest release when this repository was
   created) and enable the collectors shown in
   [examples/node_exporter.env](examples/node_exporter.env).
3. Load `prometheus/rules/*.yml` from Prometheus, Thanos Ruler, or Mimir.
4. Point Grafana provisioning at this repository and replace the datasource URL.
5. Begin at **HPC / Fleet Overview**, then follow node links into drill-down.

Validate before committing:

```bash
make check
```

## Required data sources

- Prometheus-compatible metrics backend (Prometheus, Thanos, or Mimir).
- node_exporter for host, hwmon, NFS client/server, network, and InfiniBand.
- A scheduler exporter for Slurm/PBS job, queue, partition, and allocation data.
- NVIDIA DCGM exporter or an equivalent vendor exporter for accelerators.

Node exporter cannot associate host resource use with a scheduler job. Keep job
and user labels out of node_exporter series; join or correlate those in the
scheduler/GPU layer to avoid cardinality blow-ups.

## Scale rules

- Fleet panels query recording rules, not raw per-core/per-device series.
- Variables cascade: cluster -> partition -> rack -> node.
- Fleet heatmaps show one value per node. Sensor-level series belong in the node
  drill-down.
- Use a 15-30 second scrape only for operational metrics; downsample historical
  data and retain raw data for a shorter period.
- Put user/job identity only on workload metrics, with access controls suitable
  for your organization.

