# @summary
#   Manifest to setup jenkins server
#
# @param version
#   Version to install
#
# @param repo_base_url
#   Base URL for jenkins repository
#
# @param gpg_key_filename
#   GPG key filename
#
# @param ssh_id
#   Key to be added to user
#
class profile_jenkins::server (
  String          $version,
  Sensitive       $ssh_id           = Deferred('vault_lookup::lookup', ['homelab-vm/data/jenkins', { field => 'ssh_key_priv' }]),
  Stdlib::Httpurl $repo_base_url    = 'https://pkg.jenkins.io',
  String          $gpg_key_filename = 'jenkins.io-2023.key',
) {
  # General
  user { 'jenkins':
    ensure     => present,
    managehome => true,
    shell      => '/usr/bin/false',
  }

  file { '/home/jenkins/.ssh/id_rsa':
    ensure  => file,
    content => $ssh_id,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0600',
  }

  yumrepo { 'jenkins-repo':
    ensure  => present,
    descr   => 'Jenkins',
    enabled => 1,
    baseurl => "${repo_base_url}/redhat-stable/",
    gpgkey  => "${repo_base_url}/redhat-stable/${gpg_key_filename}",
  }

  yumrepo { 'opentofu-repo':
    ensure  => present,
    descr   => 'Opentofu',
    enabled => 1,
    baseurl => 'https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/$basearch',
    gpgkey  => 'https://get.opentofu.org/opentofu.gpg',
  }

  $packages = ['fontconfig', 'java-17-openjdk', 'jenkins','ansible-core', 'tofu']
  $packages.each | $package | {
    package { $package:
      ensure => present,
    }
  }

  exec { 'Install ansible community-collection':
    command => '/usr/bin/ansible-galaxy collection install community.general -p /usr/share/ansible/collections/',
    user    => 'root',
    creates => '/usr/share/ansible/collections/ansible_collections/community',
  }

  service { 'jenkins':
    ensure  => 'running',
    enable  => true,
    require => Package['jenkins'],
  }
}
