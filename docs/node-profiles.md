# Node profiles

A node profile declares what a class of node is expected to contain. It detects
misbuilt nodes, missing DIMMs, incorrect BIOS CPU visibility, and configuration
drift without treating hostnames as hardware metadata.

## Contract

Assign every scrape target a stable `node_profile` label, for example
`cpu-standard-v1`, `gpu-h100-v1`, or `login-v2`. Deploy a matching Prometheus
textfile to node_exporter's textfile collector directory:

```text
hpc_node_profile_info{node_profile="cpu-standard-v1",vendor="example",model="compute-gen1"} 1
hpc_node_profile_cpu_threads 192
hpc_node_profile_memory_bytes 824633720832
hpc_node_profile_gpu_count 0
hpc_node_profile_local_storage_bytes 3840755982336
```

Use configuration management to install the appropriate file atomically on each
node. The scrape target supplies `cluster`, `node`, and `node_profile`, so the
numeric expectation metrics should not repeat those labels.

The supplied rules compare online CPU threads and memory against the profile.
Memory allows a two-percent difference for firmware reservations. GPU count and
local storage are included in the schema but require an accelerator/inventory
exporter before they can be compared reliably.

Profile changes should be versioned (`cpu-standard-v2`) rather than silently
editing the meaning of an existing profile. This preserves historical context.

