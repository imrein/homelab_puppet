# @summary
#   Manifest to setup vault service
#
class profile_vault::service {
  service { 'vault':
    ensure => running,
    enable => true,
  }

  exec { 'vault-reload':
    command     => '/usr/bin/systemctl reload vault',
    refreshonly => true,
  }
}
