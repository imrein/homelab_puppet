# @summary
#   Manifest to setup a grafana server
#
# @param datasource_prometheus
#   The datasource for the prometheus server
#
class profile_grafana::server (
  String  $datasource_prometheus,
) {
  package { 'grafana':
    ensure => 'present',
  }

  file { '/etc/grafana/provisioning/datasources/sample.yaml':
    content => epp("${module_name}/sample.yaml.epp", {
        datasource_prometheus => $datasource_prometheus,
    }),
    owner   => 'root',
    group   => 'root',
  }

  service { 'grafana-server':
    ensure => 'running',
    enable => true,
  }
}
