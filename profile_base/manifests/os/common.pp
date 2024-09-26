# @summary
#   Manifest for general setup on all nodes
#
# @param timezone
#   Timezone of the node
#
# @param vault_address
#   Address of the vault server
#
# @param main_user
#   User to be created
#
# @param ssh_keys
#   Keys to be added
#
# @param ssh_id
#   Key to be added to user
#
class profile_base::os::common (
  String        $timezone,
  String        $vault_address,
  String        $main_user,
  Array[String] $ssh_keys,
  Sensitive     $ssh_id = Deferred('vault_lookup::lookup', ['homelab-vm/data/general', { field => 'ssh_key_priv' }]),
) {
  # Install base packages
  include profile_base::packages

  # Include monitoring services
  include profile_prometheus::node_exporter
  include profile_grafana::promtail

  # General setup
  class { 'timezone':
    timezone => $timezone,
  }

  user { $main_user:
    ensure     => present,
    managehome => true,
  }

  $ssh_keys.each |$key| {
    ssh_authorized_key { $key:
      ensure => present,
      user   => $main_user,
      type   => 'ssh-rsa',
      key    => lookup("sshkey::${key}"),
    }
  }

  file { "/home/${main_user}/.ssh/id_rsa":
    ensure  => file,
    content => $ssh_id,
    owner   => $main_user,
    group   => $main_user,
    mode    => '0600',
  }

  service { 'chronyd':
    ensure  => 'running',
    enable  => true,
    require => Package['chrony'],
  }

  file { '/etc/environment':
    ensure  => file,
    content => epp("${module_name}/env_variables.epp", {
        vault_address => $vault_address,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Puppet run every 2 hours
  cron { 'Puppetrun':
    ensure  => present,
    command => '/opt/puppetlabs/bin/puppet agent -t',
    user    => 'root',
    hour    => '*/2',
    minute  => '0',
    weekday => '*',
  }
}
