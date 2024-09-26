# @summary
#   Grafana class
#
class profile_grafana {
  include profile_grafana::server
  include profile_grafana::loki
}
