# @summary
#   Manifest to backup gitea
#
class profile_gitea::backup {
  $backup_user          = lookup('profile_base::os::common::main_user')
  $backup_target_server = lookup('profile_base::os::common::backup_target_server')

  file { '/usr/local/bin/backup-gitea':
    ensure  => file,
    content => epp("${module_name}/backup.sh.epp", {
        user   => $backup_user,
        server => $backup_target_server
    }),
    mode    => '0755',
  }

  systemd::timer { 'backup-gitea.timer':
    ensure          => present,
    timer_content   => file("${module_name}/backup.timer"),
    service_content => file("${module_name}/backup.service"),
    enable          => true,
    active          => true,
  }
}