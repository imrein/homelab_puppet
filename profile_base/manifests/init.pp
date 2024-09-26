# @summary
#   Base class for my nodes
# 
class profile_base {
  include profile_base::os::common
  include profile_base::motd
  include profile_base::ssh

  if $facts['os'] != undef {
    case "${facts['os']['family']}_${facts['os']['release']['major']}" {
      'RedHat_8': {
        include profile_base::os::rhel8
      }
      'RedHat_9': {
        include profile_base::os::rhel9
      }
      'Debian_12': {
        include profile_base::os::debian12
      }
      default: {
        include profile_base::os::rhel8
      }
    }
  }
}
