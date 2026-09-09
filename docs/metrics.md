# Metric coverage

## node_exporter

The Linux node_exporter provides the host substrate:

| Area | Collector | Notes |
|---|---|---|
| CPU/load/memory | `cpu`, `loadavg`, `meminfo` | Enabled by default |
| Temperature | `hwmon`, optionally `thermal_zone` | Normalize chip/sensor labels carefully |
| Pressure | `pressure` | Linux PSI; kernel support required |
| Disk/filesystem | `diskstats`, `filesystem`, `nvme` | NVMe exposes inventory, not full SMART health |
| Ethernet | `netdev`, `netclass`, `netstat`, `softnet` | Interface speed may be missing on some drivers |
| NFS client/server | `nfs`, `nfsd`, `mountstats` | `mountstats` is optional and can be expensive |
| InfiniBand/Omni-Path | `infiniband` | Driver/kernel counter availability varies |
| Power | `rapl` | CPU/package energy where exposed by sysfs |
| Reliability | `edac`, `mdadm`, `xfs`, `zfs` | Enable only where applicable |

Check collector success and scrape duration after enabling optional collectors.
For containerized node_exporter, mount the host root, `/proc`, and `/sys`
correctly; a host systemd service is usually simpler for HPC nodes.

## Additional exporters

Node exporter intentionally does not provide everything needed for HPC:

- **Scheduler:** jobs, users/accounts, allocation, node drain reason, queue wait,
  requested versus used resources, and partition capacity.
- **GPU/accelerator:** temperature, power, utilization, memory, ECC/XID errors,
  interconnect, and process/job attribution. Use DCGM for NVIDIA.
- **BMC/facility:** fan, inlet/exhaust temperature, PSU, chassis power, and coolant
  telemetry using Redfish/IPMI or site systems.
- **High-detail storage:** NFS server appliance/exporter telemetry, Lustre,
  BeeGFS, GPFS/Spectrum Scale, Ceph, or vendor-specific exporters.
- **Fabric manager:** switch/port topology and congestion telemetry. Host IB
  counters alone cannot locate every fabric-wide fault.

## Label contract

All host metrics should receive these target labels during service discovery:

```yaml
cluster: atlas
partition: cpu
rack: r01
chassis: c03
role: compute
hardware_class: zen5-192c
```

Keep `instance` as the scrape endpoint and create a stable `node` label for the
scheduler hostname. Avoid volatile labels (job ID, username, IP allocation) on
host metrics. The label contract is the foundation for usable heatmaps at scale.

