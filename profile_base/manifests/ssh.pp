# @summary
#   Class to install and setup SSH
#
# @param ssh_package_name
#   SSH package to install
#
# @param ssh_service_name
#   SSH service name
#
# @param ssh_listen_address
#   SSH listen address
#
# @param ssh_port
#   SSH port to be used and listen on
#
# @param ssh_permit_root_login
#   Wether root should be allowed to login through SSH
#
# @param ssh_password_authentication
#   Wether root should be allowed to login through SSH with a password
#
# @param ssh_print_motd
#   Wether the motd should be printed out on login
#
# @param ssh_x11_forwarding
#   Wether x11 should be forwarded through SSH
#
# @param ssh_hostkey_file  
#   SSH hostkey file name(s)
# 
class profile_base::ssh (
  String                   $ssh_package_name             = 'openssh-server',
  String                   $ssh_service_name             = 'sshd',
  Stdlib::Ip::Address      $ssh_listen_address           = '0.0.0.0',
  Stdlib::Port             $ssh_port                     = 22,
  String                   $ssh_permit_root_login        = 'without-password',
  Boolean                  $ssh_password_authentication  = false,
  Boolean                  $ssh_print_motd               = false,
  Boolean                  $ssh_x11_forwarding           = false,
  Array[String]            $ssh_hostkey_file             = [],
) {
  class { 'ssh':
    server_options => {
      'PermitRootLogin'        => $ssh_permit_root_login,
      'PasswordAuthentication' => $ssh_password_authentication,
      'X11Forwarding'          => $ssh_x11_forwarding,
      'PrintMotd'              => $ssh_print_motd,
      'HostKey'                => $ssh_hostkey_file,
      'UsePAM'                 => 'yes',
      'Port'                   => $ssh_port,
    },
  }
}
