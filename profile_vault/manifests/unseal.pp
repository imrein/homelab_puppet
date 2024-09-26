# @summary
#   Manifest to setup automatic unsealing
#
class profile_vault::unseal {
  file { '/usr/local/bin/vault-unseal':
    ensure  => file,
    mode    => '0700',
    content => epp("${module_name}/unseal.epp"),
  }

  # Unseal vault every 5mins
  cron { 'Vault Unseal':
    ensure  => present,
    command => '/usr/local/bin/vault-unseal',
    user    => 'root',
    hour    => '*',
    minute  => '*/5',
  }
}
