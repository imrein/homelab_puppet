# @summary
#   Prometheus class
#
class profile_prometheus {
  include profile_prometheus::node_exporter
  include profile_prometheus::server
}
