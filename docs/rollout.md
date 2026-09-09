# Rollout and sizing

1. Pilot one rack and inventory which hwmon, NFS, NIC, and IB metrics actually
   appear. Sensor names and driver counters vary by platform.
2. Establish the label contract in service discovery and verify uniqueness of
   `(cluster, node)`.
3. Load recording rules, then dashboards. Measure query latency at full intended
   time ranges before fleet-wide rollout.
4. Add alerts with hardware-class-specific thermal thresholds and site runbooks.
5. Expand by rack while watching Prometheus samples/s, active series, scrape
   duration, rule duration, and Grafana query latency.

Recommended starting points, to be capacity-tested rather than treated as fixed:

- 15-30 second scrape for node health and fabric counters.
- 30-60 days raw retention; long-term object storage for 1+ year.
- 30 second dashboard refresh on fleet pages; no auto-refresh on trend pages.
- Recording rules evaluated every 30 seconds for current state and every 5
  minutes for trend aggregates.
- HA collectors/backends and remote object storage once monitoring is itself a
  production dependency.

For very large fleets, shard collection by cluster or failure domain and query
through Thanos/Mimir. Grafana should use the global query layer while retaining a
cluster variable and datasource-level timeouts.

