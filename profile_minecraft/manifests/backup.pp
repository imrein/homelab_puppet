# @summary
#   Manifest to backup minecraft server
#
class profile_minecraft::backup {
  $backup_user          = lookup('profile_base::os::common::main_user')
  $backup_target_server = lookup('profile_base::os::common::backup_target_server')

  # Full backup (daily)
  file { '/usr/local/bin/backup-minecraft-full':
    ensure  => file,
    content => epp("${module_name}/backup_full.sh.epp", {
        user   => $backup_user,
        server => $backup_target_server
    }),
    mode    => '0755',
  }

  systemd::timer { 'backup-minecraft-full.timer':
    ensure          => present,
    timer_content   => file("${module_name}/backup_full.timer"),
    service_content => file("${module_name}/backup_full.service"),
    enable          => true,
    active          => true,
  }

  # Worlds backup (4h)
  file { '/usr/local/bin/backup-minecraft-worlds':
    ensure  => file,
    content => epp("${module_name}/backup_worlds.sh.epp", {
        user   => $backup_user,
        server => $backup_target_server
    }),
    mode    => '0755',
  }

  systemd::timer { 'backup-minecraft-worlds.timer':
    ensure          => present,
    timer_content   => file("${module_name}/backup_worlds.timer"),
    service_content => file("${module_name}/backup_worlds.service"),
    enable          => true,
    active          => true,
  }
}
