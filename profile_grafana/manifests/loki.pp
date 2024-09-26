# @summary
#   Manifest to setup a Loki server
#
# @param version
#   Version to installed
#
# @param package_type
#   Type of package to install
#
class profile_grafana::loki (
  String  $version,
  String  $package_type = 'linux-amd64',
) {
  user { 'loki':
    ensure     => present,
    managehome => false,
    shell      => '/usr/bin/false',
  }

  # Binary && systemd
  archive { '/tmp/loki.zip':
    ensure       => present,
    source       => "https://github.com/grafana/loki/releases/download/v${version}/loki-${package_type}.zip",
    path         => '/tmp/loki.zip',
    extract      => true,
    extract_path => '/usr/local/bin/',
    cleanup      => true,
    creates      => '/usr/local/bin/loki-linux-amd64',
    notify       => Service['loki'],
  }

  file { '/etc/loki':
    ensure => directory,
    owner  => 'loki',
    group  => 'loki',
  }

  file { '/etc/loki/loki.yaml':
    content => epp("${module_name}/loki.yaml.epp"),
    owner   => 'loki',
    group   => 'loki',
  }

  file { '/etc/systemd/system/loki.service':
    content => file("${module_name}/loki.service"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'loki':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/systemd/system/loki.service'],
  }
}
