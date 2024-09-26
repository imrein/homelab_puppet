# @summary
#   Manifest to setup node_exporter
#
# @param version
#   Version to install
#
# @param package_type
#   Type of package to install
#
class profile_prometheus::node_exporter (
  String  $version,
  String  $package_type = 'linux-amd64',
) {
  # General
  user { 'node_exporter':
    ensure     => present,
    managehome => false,
    shell      => '/usr/bin/false',
  }

  # Binary && systemd
  if $::facts['node_exporter_version'] != $version {
    exec { 'node_exporter_stop':
      command => '/bin/systemctl stop node_exporter',
      onlyif  => '/usr/bin/test -e /usr/local/bin/node_exporter',
    }

    archive { '/tmp/node_exporter.tar.gz':
      ensure          => present,
      source          => "https://github.com/prometheus/node_exporter/releases/download/v${version}/node_exporter-${version}.${package_type}.tar.gz",
      path            => '/tmp/node_exporter.tar.gz',
      extract         => true,
      extract_command => "tar xfz %s --strip-components=1; cp -rf /tmp/node_exporter /tmp/node_exporter-${version}",
      extract_path    => '/tmp/',
      cleanup         => true,
    }

    file { '/usr/local/bin/node_exporter':
      ensure => file,
      source => "/tmp/node_exporter-${version}",
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      notify => Service['node_exporter'],
    }
  }

  file { '/etc/systemd/system/node_exporter.service':
    content => file("${module_name}/node_exporter.service"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'node_exporter':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/systemd/system/node_exporter.service'],
  }
}
