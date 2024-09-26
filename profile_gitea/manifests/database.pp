# @summary
#   Manifest to setup gitea database
#
# @param db_name
#   Database name
#
# @param db_user
#   Database user
#
# @param db_pass
#   Database user password
#
class profile_gitea::database (
  String    $db_name  = 'gitea',
  String    $db_user  = 'git',
  Sensitive $db_pass  = Deferred('vault_lookup::lookup', ['homelab-vm/data/gitea', { field => 'db_password' }]),
) {
  package { 'mariadb-server':
    ensure => 'latest',
  }

  service { 'mariadb':
    ensure  => 'running',
    enable  => true,
    require => Package['mariadb-server'],
  }

  # Unwrap password to convert it to string
  $password  = Deferred('unwrap', [$db_pass])
  mysql::db { 'gitea':
    user     => $db_user,
    password => $password,
    host     => 'localhost',
    grant    => ['ALL'],
    charset  => 'utf8',
    collate  => 'utf8_general_ci',
  }
}
