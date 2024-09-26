# @summary
#   Manifest to setup promtail
#
# @param version
#   Version to install
#
# @param package_type
#   Type of package to install
#
# @param loki_server
#   Loki server to ship to
#
# @param jobs
#   Logs that need to be shipped
#
class profile_grafana::promtail (
  String      $version,
  String      $loki_server,
  String      $package_type = 'linux-amd64',
  Array[Hash] $jobs         = [],
) {
  # General
  user { 'promtail':
    ensure     => present,
    managehome => false,
    shell      => '/usr/bin/false',
  }

  # Binary && systemd
  if $::facts['promtail_version'] != $version {
    exec { 'promtail_stop':
      command => '/bin/systemctl stop promtail',
      onlyif  => '/usr/bin/test -e /usr/local/bin/promtail',
    }

    archive { '/tmp/promtail.zip':
      ensure          => present,
      source          => "https://github.com/grafana/loki/releases/download/v${version}/promtail-${package_type}.zip",
      path            => '/usr/local/bin/promtail.zip',
      extract         => true,
      extract_command => "unzip %s -d /tmp/; mv /tmp/promtail-${package_type} /tmp/promtail-${version}",
      extract_path    => '/usr/local/bin/',
      cleanup         => true,
    }

    file { '/usr/local/bin/promtail':
      ensure => file,
      source => "/tmp/promtail-${version}",
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      notify => Service['promtail'],
    }

    exec { 'cleanup':
      command => "/bin/rm -f /tmp/promtail-${version}",
      onlyif  => '/usr/bin/test -e /usr/local/bin/promtail',
    }
  }

  file { '/etc/promtail':
    ensure => directory,
    owner  => 'promtail',
    group  => 'promtail',
  }

  file { '/etc/promtail/promtail.yaml':
    content => epp("${module_name}/promtail.yaml.epp", {
        loki_server => $loki_server,
        jobs        => $jobs,
    }),
    owner   => 'promtail',
    group   => 'promtail',
    notify  => Service['promtail'],
  }

  file { '/etc/systemd/system/promtail.service':
    content => file("${module_name}/promtail.service"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'promtail':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/systemd/system/promtail.service'],
  }
}
