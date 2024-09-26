# @summary
#   Manifest to setup gitea server
#
# @param version
#   Version to install
#
# @param package_type
#   Type of package to install
#
# @param mysql_ip
#   Mysql server
#
# @param db_name
#   Gitea database name
#
# @param gitea_user
#   Gitea user
#
# @param gitea_pass
#   Gitea user pass
#
# @param lfs_jwt_secret
#   LFS_JWT_SECRET for Gitea server
#
# @param internal_token
#   Security internal token
#
# @param jwt_secret
#   JWT secret
#
class profile_gitea::server (
  String        $version,
  Sensitive     $jwt_secret     = Deferred('vault_lookup::lookup', ['homelab-vm/data/gitea', { field => 'jwt_secret' }]),
  Sensitive     $lfs_jwt_secret = Deferred('vault_lookup::lookup', ['homelab-vm/data/gitea', { field => 'lfs_jwt_secret' }]),
  Sensitive     $internal_token = Deferred('vault_lookup::lookup', ['homelab-vm/data/gitea', { field => 'internal_token' }]),
  String        $package_type   = 'linux-amd64',
  String        $mysql_ip       = '127.0.0.1',
  String        $db_name        = 'gitea',
  String        $gitea_user     = 'git',
  Sensitive     $gitea_pass     = Deferred('vault_lookup::lookup', ['homelab-vm/data/gitea', { field => 'db_password' }]),
) {
  $ssh_id = $profile_base::os::common::ssh_id

  # General
  user { 'git':
    ensure     => present,
    managehome => true,
    shell      => '/usr/bin/bash',
  }

  file { '/home/git/.ssh/id_rsa':
    ensure  => file,
    content => $ssh_id,
    owner   => 'git',
    group   => 'git',
    mode    => '0600',
  }

  package { 'git':
    ensure => present,
  }

  # Upgrade procedure
  if $::facts['gitea_version'] != $version {
    exec { 'gitea_stop':
      command => '/bin/systemctl stop gitea',
      onlyif  => '/usr/bin/test -e /usr/local/bin/gitea',
    }

    exec { 'backup_gitea':
      command => '/bin/systemctl start backup-gitea',
      onlyif  => '/usr/bin/test -e /usr/local/bin/gitea',
    }

    file { "/tmp/gitea-${version}":
      ensure => file,
      source => "https://github.com/go-gitea/gitea/releases/download/v${version}/gitea-${version}-${package_type}",
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  # Create necessary files/dirs
  file { '/usr/local/bin/gitea':
    ensure => file,
    source => "/tmp/gitea-${version}",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/gitea':
    ensure => directory,
    owner  => 'root',
    group  => 'git',
    mode   => '0770',
  }

  file { '/etc/gitea/app.ini':
    ensure  => file,
    content => stdlib::deferrable_epp("${module_name}/app.ini.epp", {
        mysql_ip       => $mysql_ip,
        db_name        => $db_name,
        user           => $gitea_user,
        pass           => $gitea_pass,
        lfs_jwt_secret => $lfs_jwt_secret,
        internal_token => $internal_token,
        jwt_secret     => $jwt_secret,
    }),
    owner   => 'git',
    group   => 'git',
    mode    => '0600',
  }

  file { '/var/lib/gitea':
    ensure => directory,
    owner  => 'git',
    group  => 'git',
    mode   => '0750',
  }

  $dirs = ['custom','data','log']
  $dirs.each |$dir| {
    file { "/var/lib/gitea/${dir}":
      ensure => directory,
      owner  => 'git',
      group  => 'git',
      mode   => '0750',
    }
  }

  # Service
  file { '/etc/systemd/system/gitea.service':
    content => file("${module_name}/gitea.service"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'gitea':
    ensure    => 'running',
    enable    => true,
    require   => File['/etc/systemd/system/gitea.service'],
    subscribe => File['/usr/local/bin/gitea'],
  }
}
