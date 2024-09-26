# @summary
#   Manifest for RHEL 8 specifics
#
class profile_base::os::rhel8 {
  # Remove cockpit packages
  $cockpit = ['cockpit-ws','cockpit-system','cockpit-bridge']
  package { $cockpit:
    ensure => absent,
  }
}
