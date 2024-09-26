# @summary
#   Manifest to setup vault server
#
# @param repo_base_url
#   Base URL for hashicorp repository
#
# @param gpg_key
#   GPG key for hashicorp repository
#
# @param repo_gpgcheck
#   GPG key check
#
# @param repo_enabled
#   Enable hashicorp repository
#
# @param ssh_id
#   Key to be added to user
#
class profile_vault::server (
  Sensitive         $ssh_id         = Deferred('vault_lookup::lookup', ['homelab-vm/data/vault', { field => 'ssh_key_priv' }]),
  Stdlib::HTTPSUrl  $repo_base_url  = 'https://rpm.releases.hashicorp.com',
  Stdlib::HTTPSUrl  $gpg_key        = 'https://apt.releases.hashicorp.com/gpg',
  Integer[0,1]      $repo_gpgcheck  = 0,
  Integer[0,1]      $repo_enabled   = 1,
) {
  # General
  user { 'vault':
    ensure => present,
    gid    => 'vault',
    system => true,
    home   => '/var/lib/vault',
  }

  file { '/var/lib/vault/.ssh/id_rsa':
    ensure  => file,
    content => $ssh_id,
    owner   => 'vault',
    group   => 'vault',
    mode    => '0600',
  }

  file { '/var/lib/vault':
    ensure  => directory,
    owner   => 'vault',
    group   => 'vault',
    mode    => '0640',
    require => User['vault'],
  }

  group { 'vault':
    ensure => present,
    system => true,
  }

  yumrepo { 'HashiCorp':
    baseurl       => "${repo_base_url}/RHEL/\$releasever/\$basearch/stable",
    gpgcheck      => 1,
    gpgkey        => $gpg_key,
    repo_gpgcheck => $repo_gpgcheck,
    enabled       => $repo_enabled,
  }

  package { 'vault':
    ensure => present,
  }
}
