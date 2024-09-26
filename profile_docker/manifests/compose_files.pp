# @summary
#   Creating docker-compose file
#
# @param stacks
#   Stacks to create a docker-compose file for
#
# @param directory
#   Directory to create to facilitate docker-compose file
#
class profile_docker::compose_files (
  String                    $directory  = '/docker_stacks',
  Hash[String, Array[Hash]] $stacks     = {},
) {
  $user = $profile_docker::docker_user

  file { $directory:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $stacks.each |$stack_name, $containers| {
    $stack_directory  = "${directory}/${stack_name}"

    $containers.each |$container| {
      if $container['name'] == 'jellyfin' {
        include profile_docker::jellyfin::setup
      }
    }

    file { $stack_directory:
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0755',
    }

    file { "${stack_directory}/docker-compose.yaml":
      content => epp("${module_name}/docker-compose.yaml.epp", {
          stack_name => $stack_name,
          containers => $containers,
      }),
      owner   => $user,
      group   => $user,
      notify  => Exec["docker-compose_up_${stack_name}"],
    }

    exec { "docker-compose_up_${stack_name}":
      command     => '/usr/bin/docker-compose up -d',
      cwd         => $stack_directory,
      refreshonly => true,
      timeout     => 0,
      user        => $user,
    }
  }
}
