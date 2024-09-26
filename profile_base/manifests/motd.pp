# @summary
#   Class to setup motd.
#
class profile_base::motd {
  file { '/etc/motd':
    content => epp("${module_name}/motd.epp"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
