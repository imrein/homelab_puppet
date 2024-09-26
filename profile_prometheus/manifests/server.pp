# @summary
#   Manifest to setup prometheus server
#
# @param version
#   Version to install
#
# @param package_type
#   Type of package to install
#
# @param node_targets
#   Nodes that should be targeted
#
# @param cadvisor_targets
#   Nodes that are running cadvisor
#
# @param watchtower_targets
#   Nodes that are running watchtower
#
# @param synology_target
#   Synology NAS target
#
# @param watchtower_bearer
#   Bearer token for watchtower instances
#
class profile_prometheus::server (
  String        $version,
  String        $watchtower_bearer,
  String        $synology_target,
  String        $package_type       = 'linux-amd64',
  Array[String] $node_targets       = [],
  Array[String] $cadvisor_targets   = [],
  Array[String] $watchtower_targets = [],
) {
  # General
  user { 'prometheus':
    ensure     => present,
    managehome => false,
    shell      => '/usr/bin/false',
  }

  # Binary && systemd
  if $::facts['prometheus_version'] != $version {
    exec { 'prometheus_stop':
      command => '/bin/systemctl stop prometheus',
      onlyif  => '/usr/bin/test -e /usr/local/bin/prometheus',
    }

    $filename = "prometheus-${version}.${package_type}"

    archive { '/tmp/prometheus.tar.gz':
      ensure          => present,
      source          => "https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.${package_type}.tar.gz",
      path            => "/tmp/${filename}.tar.gz",
      extract         => true,
      extract_command => "tar xfz %s ${filename}/{prometheus,promtool,consoles,console_libraries}; cp -rf ${filename}/prometheus /tmp/prometheus-${version}; cp -rf ${filename}/promtool /tmp/promtool-${version}; cp -rf ${filename}/{consoles,console_libraries} /tmp/; rm -rf prometheus-${version}.${package_type}", #lint:ignore:140chars
      extract_path    => '/tmp/',
      cleanup         => true,
    }
  }

  $directories = ['/etc/prometheus','/var/lib/prometheus']
  $directories.each |$directory| {
    file { $directory:
      ensure => directory,
      owner  => 'prometheus',
      group  => 'prometheus',
    }
  }

  $binaries = ['prometheus','promtool']
  $binaries.each |$binary| {
    file { "/usr/local/bin/${binary}":
      source => "/tmp/${binary}-${version}",
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  $consoles = ['consoles','console_libraries']
  $consoles.each |$console_dir| {
    file { "/etc/prometheus/${console_dir}":
      ensure  => directory,
      source  => "/tmp/${console_dir}",
      recurse => true,
      owner   => 'prometheus',
      group   => 'prometheus',
    }
  }

  file { '/etc/prometheus/prometheus.yaml':
    content => epp("${module_name}/prometheus.yaml.epp", {
        node_targets       => $node_targets,
        cadvisor_targets   => $cadvisor_targets,
        watchtower_targets => $watchtower_targets,
        watchtower_bearer  => $watchtower_bearer,
        synology_target    => $synology_target
    }),
    owner   => 'prometheus',
    group   => 'prometheus',
  }

  file { '/etc/systemd/system/prometheus.service':
    content => file("${module_name}/prometheus.service"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'prometheus':
    ensure    => 'running',
    enable    => true,
    require   => File['/etc/systemd/system/prometheus.service'],
    subscribe => [
      File['/usr/local/bin/prometheus'],
      File['/etc/prometheus/prometheus.yaml'],
    ],
  }
}
