# @summary
#   Manifest to backup docker data
#
class profile_docker::backup {
  $backup_user          = $profile_docker::docker_user
  $backup_target_server = lookup('profile_base::os::common::backup_target_server')

  file { '/usr/local/bin/backup-docker':
    ensure  => file,
    content => epp("${module_name}/backup-docker.sh.epp", {
        user   => $backup_user,
        server => $backup_target_server
    }),
    mode    => '0755',
  }

  systemd::timer { 'backup-docker.timer':
    ensure          => present,
    timer_content   => file("${module_name}/backup-docker.timer"),
    service_content => file("${module_name}/backup-docker.service"),
    enable          => true,
    active          => true,
  }
}
