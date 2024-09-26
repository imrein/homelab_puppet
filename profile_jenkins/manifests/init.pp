# @summary
#   Jenkins class
#
class profile_jenkins {
  include profile_jenkins::server
  include profile_jenkins::backup
}
