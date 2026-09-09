# Information architecture

## 1. Fleet overview: answer “where is the fire?”

Keep this view sparse and fast. Its first row contains fleet-wide stat panels:
nodes down, nodes hot, CPU busy, memory pressure, filesystems near full, NFS RPC
errors, network errors, and InfiniBand errors. Below that:

- **Node health grid:** one colored cell per node, grouped by rack. Color is the
  worst current condition, not an average.
- **Temperature grid:** rows are nodes and columns are recent time. Use the
  maximum temperature across sensors per node so a hot component is not hidden.
- **CPU/memory pressure grids:** the same node ordering makes visual comparison
  easy.
- **Top offenders:** sortable table with temperature, CPU, memory, load, disk
  latency, NFS retransmits, network drops, IB errors, and scrape age.

Every node cell and table row links to the node drill-down. Defaults: 15-minute
range, 30-second refresh, and filters for cluster, partition, rack, and role.

## 2. Thermal topology: answer “what is heating up?”

Use a **status history** panel for one row per node over time. Grafana's generic
heatmap bins values into distributions; status history better preserves node
identity on the Y axis. Apply fixed thresholds (example: <70 C green, 70-80 C
yellow, 80-90 C orange, >=90 C red) and tune them by hardware class.

Panels:

- Current maximum by node, ordered by rack/chassis/slot.
- Maximum temperature per node over time.
- Rack p50/p95/max to reveal cooling-domain problems.
- Sensor spread (`max - min`) per node to detect bad contact or airflow.
- Nodes above warning/critical thresholds and sensors that disappeared.
- Long-range daily p95/max correlated with ambient or facility telemetry.

Never average all sensors for alerting. Add `hardware_class` or `model` labels so
thresholds can differ without dashboard forks.

## 3. Storage and fabric: answer “is data movement the bottleneck?”

Organize rows by path rather than exporter:

- **NFS client:** operations/s by method, retransmit rate, RPC auth/timeout/error
  rate, read/write throughput, and mount latency when mountstats is enabled.
- **NFS server:** RPC rate/errors, reply cache, thread utilization, and read/write
  bytes if compute infrastructure also hosts NFS servers.
- **Block/NVMe:** IOPS, throughput, latency, queue depth, utilization, errors, and
  filesystem capacity/inodes.
- **Ethernet:** bytes, packets, drops, errors, carrier changes, and saturation as a
  fraction of interface speed.
- **InfiniBand:** port state, data/packets, symbol/link/recovery errors, discards,
  constraint errors, and hardware counters when supported.

Show current offender tables first, then time series. Group by rack and fabric
device. Rates must use `rate()` over at least four scrape intervals.

## 4. Node drill-down: answer “why this node?”

One required `node` variable and no multi-select. Rows should cover identity and
scrape health; CPU/load/PSI; memory/NUMA; thermals/power; disk/filesystem; NFS;
Ethernet; InfiniBand; and optional GPU/scheduler context. Show raw sensor and
device labels here because the series count is bounded to one node.

## 5. Capacity and trends: answer “what should we change?”

Use downsampled or recorded hourly/daily series for 7/30/90-day views:

- p50/p95/max CPU, memory, PSI, temperature, power, and fabric throughput.
- Peak concurrent busy/down/drained nodes by partition.
- Thermal headroom and throttling frequency by hardware class.
- NFS and IB error trends normalized per transferred byte or packet.
- Scheduler utilization, queue wait, backfill effectiveness, and job efficiency
  from the scheduler exporter.

This view should never query raw per-core time series across the full fleet.

