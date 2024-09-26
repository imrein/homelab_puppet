# @summary
#   Manifest to configure vault server
#
class profile_vault::config {
  $listen_ip    = $profile_vault::listen_ip
  $raft_id      = $profile_vault::raft_id
  $skip_verify  = $profile_vault::skip_verify

  file { '/etc/vault.d':
    ensure  => directory,
    recurse => true,
  }

  file { '/etc/vault.d/vault.env':
    ensure  => file,
    mode    => '0644',
    content => '# Empty file to please systemd service',
  }

  file { '/etc/vault.d/vault.hcl':
    ensure  => file,
    mode    => '0640',
    content => epp(
      "${module_name}/vault.hcl.epp",
      {
        listen_ip => $listen_ip,
        raft_id   => $raft_id,
      }
    ),
    notify  => Exec['vault-reload'],
  }

  file { '/etc/profile.d/vault.sh':
    ensure  => file,
    mode    => '0644',
    content => epp(
      "${module_name}/vault.sh.epp",
      {
        skip_verify => $skip_verify,
      }
    ),
  }
}
