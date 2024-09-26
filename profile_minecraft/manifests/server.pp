# @summary
#   Manifest to setup minecraft server
#
# @param paper_version
#   Paper version to install
#
# @param mc_directory
#   Minecraft server location
#
# @param paper_build
#   Paper build version to install
#
# @param max_ram
#   Max RAM to be used by jar file
#
# @param min_ram
#   Min RAM to be used by jar file
#
# @param rcon_port
#   Rcon port
#
# @param rcon_pass
#   Rcon password
#
# @param mc_port
#   Minecraft port
#
# @param mc_motd
#   Minecraft server motd
#
class profile_minecraft::server (
  Stdlib::Port  $rcon_port,
  String        $rcon_pass,
  Stdlib::Port  $mc_port,
  String        $mc_motd,
  String        $paper_version,
  String        $paper_build,
  String        $mc_directory   = '/opt/minecraft_server',
  String        $max_ram        = 'Xmx6g',
  String        $min_ram        = 'Xms6g',
) {
  # General
  user { 'minecraft':
    ensure     => present,
    managehome => true,
    shell      => '/bin/bash',
  }

  $packages = ['fontconfig', 'java-21-openjdk']
  $packages.each | $package | {
    package { $package:
      ensure => present,
    }
  }

  # Server files
  file { $mc_directory:
    ensure => directory,
    owner  => 'minecraft',
    group  => 'minecraft',
    mode   => '0644',
  }

  file { "${mc_directory}/paper.jar":
    ensure => file,
    source => "https://api.papermc.io/v2/projects/paper/versions/${paper_version}/builds/${paper_build}/downloads/paper-${paper_version}-${paper_build}.jar",
    owner  => 'minecraft',
    group  => 'minecraft',
    mode   => '0744',
  }

  $config_files = ['spigot.yml','permissions.yml','commands.yml']
  $config_files.each |$config| {
    file { "${mc_directory}/${config}":
      content => epp("${module_name}/${config}.epp"),
      owner   => 'minecraft',
      group   => 'minecraft',
      mode    => '0644',
    }
  }

  file { "${mc_directory}/server.properties":
    content => epp("${module_name}/server.properties.epp", {
        rcon_port => $rcon_port,
        rcon_pass => $rcon_pass,
        mc_port   => $mc_port,
        mc_motd   => $mc_motd,
    }),
    owner   => 'minecraft',
    group   => 'minecraft',
    mode    => '0644',
  }

  file { "${mc_directory}/eula.txt":
    content => file("${module_name}/eula.txt"),
    owner   => 'minecraft',
    group   => 'minecraft',
    mode    => '0644',
  }

  # Service
  file { '/etc/systemd/system/minecraft_server.service':
    content => epp("${module_name}/minecraft_server.service.epp", {
        max_ram => $max_ram,
        min_ram => $min_ram,
    }),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'minecraft_server':
    ensure    => 'running',
    enable    => true,
    require   => File['/etc/systemd/system/minecraft_server.service'],
    subscribe => File["${mc_directory}/paper.jar"],
  }
}
