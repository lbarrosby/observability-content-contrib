resource "signalfx_detector" "qdrant_dead_replicas" {
  name         = "${var.o11y_prefix} Qdrant - Dead shard replicas"
  description  = "Alerts when a Qdrant node reports a dead shard replica for 5m. That copy lost its data and queries may return partial results until it recovers"
  program_text = <<-EOF
    A = data('collection_dead_replicas').max(by=['host.name']).publish(label='A')
    detect(when(A > threshold(0), lasting='5m')).publish('Qdrant dead shard replicas')
  EOF
  rule {
    detect_label       = "Qdrant dead shard replicas"
    severity           = "Critical"
    parameterized_body = var.message_body
  }
}

resource "signalfx_detector" "qdrant_high_error_ratio" {
  name         = "${var.o11y_prefix} Qdrant - High REST 5xx ratio"
  description  = "Alerts when more than 5% of the REST responses of a Qdrant node are 5xx for 10m. Client errors (4xx) are not counted"
  program_text = <<-EOF
    E = data('rest_responses_total', filter=filter('status', '5*'), rollup='rate').sum(by=['host.name'])
    T = data('rest_responses_total', rollup='rate').sum(by=['host.name'])
    A = (E / T).publish(label='A')
    detect(when(A > threshold(0.05), lasting='10m')).publish('Qdrant REST 5xx ratio above 5%')
  EOF
  rule {
    detect_label       = "Qdrant REST 5xx ratio above 5%"
    severity           = "Warning"
    parameterized_body = var.message_body
  }
}
