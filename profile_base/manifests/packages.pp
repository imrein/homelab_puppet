# @summary
#   Class to install packages
#
# @param default_packages
#   The default packages to be installed
#
class profile_base::packages (
  Array[String] $default_packages = [],
) {
  package { $default_packages:
    ensure => present,
  }
}
