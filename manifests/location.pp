# == Define: foreman::location
#
# Adds a location to the Foreman web UI.
#
# NOTE: Setting locations in Puppet will take precedence over all changes made in the web browser.
# Changes made manually in the web browser will be automatically overwritten on the next Puppet
# run.
#
# == Parameters
#
# [*name*]
#   Type: String
#
#   The name you give this define will be the name of the location created in foreman
# [*admin_user*]
#   Type: String/Username
#   Default: $::foreman::admin_user
#
#   The admin user, used for connecting to the Foreman REST API.
#
# [*admin_password*]
#   Type: String/Password
#   Default: $::foreman::admin_password
#
#   The password for the admin user.
#
# [*host*]
#   Type: FQDN/String
#   Default: $::foreman::server
#
#   The host where the foreman service is running. Used in order to
#   connect to the Foreman REST API.
#
# [*ensure*]
#   Type: String/Ensure
#   Default: 'present'
#
#   Tells the resource to either create or remove itself. Valid values are
#   'present' and 'absent'
#
# == Authors
#
# * Michael Riddle <mriddle@onyxpoint.com>
#
define foreman::location (
  $admin_user     = $::foreman::admin_user,
  $admin_password = $::foreman::admin_password,
  $host           = $::foreman::server,
  $ensure         = 'present'
){
  include '::foreman'

  foreman_location { $name:
    admin_user     => $admin_user,
    admin_password => $admin_password,
    host           => $host,
    ensure	   => $ensure
  }
}
