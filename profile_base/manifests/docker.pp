# @summary
#   Manifest for docker
#
include docker

class { 'docker::compose':
  ensure  => present,
  version => '1.9.0',
}
