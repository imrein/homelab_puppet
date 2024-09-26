# @summary
#   Gitea class
#
class profile_gitea {
  include profile_gitea::database
  include profile_gitea::backup
  include profile_gitea::server
}
