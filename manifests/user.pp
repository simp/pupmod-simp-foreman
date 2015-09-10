# == Define: foreman::add_user
#
# Adds a user to authenticate to the Foreman web UI or REST API.
#
# NOTE: Setting users in Puppet will take precedence over all changes made in the web browser.
# Changes made manually in the web browser will be automatically overwritten on the next Puppet
# run.
#
# == Parameters
#
# [*auth_source*]
#   Type: String
#   Default: None - Required parameter.
#
#   The name of the authentication source for this user. If this user
#   is to be authenticated internally by foreman, this should be set
#   to 'Internal'. Otherwise, this should be the name of the LDAP
#   authentication source that has been defined inside of the Foreman.
#
# [*api_admin*]
#   Type: Boolean
#   Default: false
#
#   Whether or not this is the admin user who connects to the REST API
#   in order to perform transactions.
#   NOTE: Unless you are positive this is the primary admin user, do
#   not set this variable to true. This user should really only be
#   used internally, not for basic use in the web UI.
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
define foreman::user(
  $auth_source,
  $password       = '',
  $api_admin      = false,
  $web_admin      = false,
  $email          = '',
  $firstname      = '',
  $lastname       = ''
){
  include '::foreman'

  $admin_user     = $::foreman::admin_user
  $admin_password = $::foreman::admin_password
  $host           = $::foreman::server

  $l_email = empty($email) ? {
    true    => "${name}@${::domain}",
    default => $email
  }

  foreman_user { $name:
    admin_user     => $admin_user,
    admin_password => $admin_password,
    host           => $host,
    auth_source    => $auth_source,
    api_admin      => $api_admin,
    password       => $password,
    web_admin      => $web_admin,
    email          => $l_email,
    firstname      => $firstname,
    lastname       => $lastname
  }
}
