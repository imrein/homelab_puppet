# @summary
#   Vault class
#
# @param version
#   Version to install
#
# @param listen_ip
#   IP for vault config
#
# @param raft_id
#   ID for raft
#
# @param skip_verify
#   Skip the vault verify
#
class profile_vault (
  String              $version      = 'present',
  Stdlib::IP::Address $listen_ip    = '127.0.0.1',
  String              $raft_id      = 'node1',
  Boolean             $skip_verify  = true
) {
  include profile_vault::server
  include profile_vault::config
  include profile_vault::service
  include profile_vault::unseal
  include profile_vault::backup
}
