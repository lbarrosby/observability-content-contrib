resource "signalfx_dashboard_group" "qdrant_dashboard_group" {
  name        = "${var.o11y_prefix} Qdrant"
  description = "Dashboards for Qdrant vector databases"
}

resource "signalfx_time_chart" "qdrant_requests" {
  name        = "REST requests per second by status"
  description = "REST responses per second, by HTTP status"

  program_text = <<-EOF
        A = data('rest_responses_total', rollup='rate').sum(by=['status']).publish(label='Requests/s')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_requests_endpoint" {
  name        = "REST requests per second by endpoint"
  description = "REST responses per second, by endpoint"

  program_text = <<-EOF
        A = data('rest_responses_total', rollup='rate').sum(by=['endpoint']).publish(label='Requests/s')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_latency" {
  name        = "Average REST response time (s)"
  description = "Average response time by endpoint, from the _sum and _count series of rest_responses_duration_seconds"

  program_text = <<-EOF
        S = data('rest_responses_duration_seconds_sum', rollup='delta').sum(by=['endpoint'])
        C = data('rest_responses_duration_seconds_count', rollup='delta').sum(by=['endpoint'])
        A = (S / C).publish(label='Average (s)')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_max_latency" {
  name        = "Longest REST response time (s)"
  description = "Longest response time reported by Qdrant, by endpoint"

  program_text = <<-EOF
        A = data('rest_responses_max_duration_seconds').max(by=['endpoint']).publish(label='Max (s)')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_points" {
  name        = "Points per collection"
  description = "Points in each collection (id), summed across nodes"

  program_text = <<-EOF
        A = data('collection_points').sum(by=['id']).publish(label='Points')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_optimizations" {
  name        = "Running optimizations"
  description = "Optimizations running in each collection"

  program_text = <<-EOF
        A = data('collection_running_optimizations').sum(by=['id']).publish(label='Optimizations')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_update_queue" {
  name        = "Update queue"
  description = "Update operations waiting and points whose update is deferred, by collection"

  program_text = <<-EOF
        A = data('collection_update_queue_length').sum(by=['id']).publish(label='Queued updates')
        B = data('collection_update_queue_deferred_points').sum(by=['id']).publish(label='Deferred points')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_replicas" {
  name        = "Replicas"
  description = "Lowest number of active replicas and number of dead replicas, by node"

  program_text = <<-EOF
        A = data('collection_active_replicas_min').min(by=['host.name']).publish(label='Active replicas (min)')
        B = data('collection_dead_replicas').max(by=['host.name']).publish(label='Dead replicas')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_shard_transfers" {
  name        = "Shard transfers"
  description = "Incoming, outgoing and failed shard transfers"

  program_text = <<-EOF
        A = data('collection_shard_transfer_incoming').sum().publish(label='Incoming')
        B = data('collection_shard_transfer_outgoing').sum().publish(label='Outgoing')
        C = data('collection_shard_transfer_failed').sum().publish(label='Failed')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_time_chart" "qdrant_memory" {
  name        = "Memory (bytes)"
  description = "Resident and allocated memory, by node"

  program_text = <<-EOF
        A = data('memory_resident_bytes').max(by=['host.name']).publish(label='Resident')
        B = data('memory_allocated_bytes').max(by=['host.name']).publish(label='Allocated')
        EOF

  plot_type         = "LineChart"
  show_data_markers = false
}

resource "signalfx_dashboard" "qdrant_dashboard" {
  name            = "Qdrant"
  dashboard_group = signalfx_dashboard_group.qdrant_dashboard_group.id
  time_range      = "-1h"

  variable {
    property       = "id"
    alias          = "collection"
    apply_if_exist = true
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_requests.id
    width    = 4
    height   = 1
    row      = 0
    column   = 0
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_requests_endpoint.id
    width    = 4
    height   = 1
    row      = 0
    column   = 4
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_latency.id
    width    = 4
    height   = 1
    row      = 0
    column   = 8
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_max_latency.id
    width    = 4
    height   = 1
    row      = 1
    column   = 0
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_points.id
    width    = 4
    height   = 1
    row      = 1
    column   = 4
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_optimizations.id
    width    = 4
    height   = 1
    row      = 1
    column   = 8
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_update_queue.id
    width    = 4
    height   = 1
    row      = 2
    column   = 0
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_replicas.id
    width    = 4
    height   = 1
    row      = 2
    column   = 4
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_shard_transfers.id
    width    = 4
    height   = 1
    row      = 2
    column   = 8
  }

  chart {
    chart_id = signalfx_time_chart.qdrant_memory.id
    width    = 4
    height   = 1
    row      = 3
    column   = 0
  }
}
