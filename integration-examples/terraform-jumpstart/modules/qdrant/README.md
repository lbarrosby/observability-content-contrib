# Qdrant

Dashboard group, dashboard and detectors for [Qdrant](https://qdrant.tech) vector databases.

Qdrant serves Prometheus metrics on the `/metrics` path of its REST API (port `6333` by default). Scrape it with the `prometheus` receiver of the Splunk Distribution of the OpenTelemetry Collector and add the receiver to the metrics pipeline:

```yaml
receivers:
  prometheus/qdrant:
    config:
      scrape_configs:
        - job_name: qdrant
          scrape_interval: 15s
          static_configs:
            - targets: ["localhost:6333"]
          metric_relabel_configs:
            - source_labels: [__name__]
              regex: "(collections?_.*|rest_responses_.*|snapshot_.*|memory_.*|cluster_.*|app_.*)"
              action: keep

service:
  pipelines:
    metrics:
      receivers: [hostmetrics, otlp, prometheus/qdrant]
```

When Qdrant has an API key, `/metrics` requires it too. Qdrant accepts the key as a bearer token, so add `authorization: {type: Bearer, credentials_file: /path/to/key}` to the scrape config.

The charts and detectors use the metric names Qdrant defines in `src/common/metrics` and were checked against the `/metrics` output of Qdrant 1.20. Per-collection metrics carry the collection name in the `id` label (`collection_points`, `collection_running_optimizations`, `collection_update_queue_length`); REST metrics carry `method`, `endpoint` and `status`. If `service.metrics_prefix` is set in the Qdrant configuration, every metric name gets that prefix and the charts stay empty.

Latency charts show averages computed from the `_sum` and `_count` series of `rest_responses_duration_seconds`.

## Dashboard

- REST requests per second by status
- REST requests per second by endpoint
- Average REST response time by endpoint
- Longest REST response time by endpoint
- Points per collection
- Running optimizations
- Update queue length and deferred points
- Active and dead replicas
- Incoming, outgoing and failed shard transfers
- Resident and allocated memory

The `collection` variable filters the per-collection charts on the `id` label.

## Detectors

| Detector | Condition |
|---|---|
| Dead shard replicas | `collection_dead_replicas` above 0 for 5m |
| High REST 5xx ratio | 5xx share of `rest_responses_total` above 5% for 10m |

Tune the thresholds to your workload.

## Deploy only this module

``` text
terraform apply -target=module.qdrant
```
