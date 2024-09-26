# @summary
#   Base class for docker
#
# @param compose_version
#   Version of docker-compose to be installed
# 
# @param docker_user
#   User that will mainly use docker
#
# @param includes_jellyfin
#   Should jellyfin be installed on the node
# 
class profile_docker (
  String  $compose_version,
  String  $docker_user,
  Boolean $includes_jellyfin  = false,
) {
  if $facts['os']['family'] == 'RedHat' {
    yumrepo { 'docker-repo':
      ensure  => present,
      descr   => 'Docker',
      enabled => 1,
      baseurl => "https://download.docker.com/linux/centos/${facts['os']['release']['major']}/${facts['os']['architecture']}/stable/",
      gpgkey  => 'https://download.docker.com/linux/centos/gpg',
    }

    package { 'docker-ce':
      ensure  => 'installed',
      require => Yumrepo['docker-repo'],
    }
  }

  if $facts['os']['family'] == 'Debian' {
    apt::source { 'docker':
      location     => 'https://download.docker.com/linux/debian',
      architecture => 'aarch64',
      release      => 'bullseye',
      repos        => 'stable',
      key          => {
        id     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
        source => 'https://download.docker.com/linux/debian/gpg',
      },
    }

    exec { 'apt-update':
      command   => '/usr/bin/apt update',
      subscribe => Apt::Source['docker'],
    }

    package { 'docker-ce':
      ensure  => 'installed',
      require => Apt::Source['docker'],
    }
  }

  $docker_dirs = ['/etc/docker','/etc/systemd/system/docker.service.d/']
  $docker_dirs.each | $dir | {
    file { $dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
    }
  }

  file { '/etc/docker/daemon.json':
    content => file("${module_name}/daemon.json"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { '/etc/systemd/system/docker.service.d/override.conf':
    content => file("${module_name}/override.conf"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => [Exec['daemon-reload'], Service['docker']],
  }

  group { 'docker':
    members => $docker_user,
  }

  exec { 'docker membership':
    unless  => "/bin/getent group docker | /bin/cut -d: -f4 | /bin/grep -q ${docker_user}",
    command => "/sbin/usermod -aG docker ${docker_user}",
    require => Group['docker'],
  }

  exec { 'daemon-reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    subscribe   => File['/etc/systemd/system/docker.service.d/override.conf'],
  }

  service { 'docker':
    ensure    => 'running',
    enable    => true,
    name      => 'docker',
    require   => Package['docker-ce'],
    subscribe => File['/etc/systemd/system/docker.service.d/override.conf'],
  }

  file { '/usr/bin/docker-compose':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-linux-${facts['os']['architecture']}",
  }

  include profile_docker::compose_files
  include profile_docker::backup
  if $includes_jellyfin {
    include profile_docker::jellyfin::setup
  }
}
