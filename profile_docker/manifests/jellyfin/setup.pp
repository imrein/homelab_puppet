# @summary
#   Extra stuff (jellyfin specific)
#
class profile_docker::jellyfin::setup {
  $user   = lookup('profile_base::os::common::main_user')
  $server = lookup('profile_base::os::common::media_server')

  # Mount nfs share with media files
  file { '/mnt/media':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  mount { '/mnt/media':
    ensure  => mounted,
    device  => "${server}:/volume1/media",
    fstype  => 'nfs',
    options => 'defaults',
  }

  $container_mounts = ['jellyfin','jellyseerr','jellystat']
  $container_mounts.each | $mount | {
    file { "/docker_stacks/jellyfin/${mount}":
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0755',
    }
  }

  # GPU passtrough has to be enabled before the container will work
  # (https://3os.org/infrastructure/proxmox/gpu-passthrough/igpu-passthrough-to-vm/#linux-virtual-machine-igpu-passthrough-configuration)
}
