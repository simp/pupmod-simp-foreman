# == Define: foreman::smart_proxy
#
# Adds a smart proxy to the Foreman web UI.
#
# NOTE: Setting smart proxies in Puppet will take precedence over all changes made in the web browser.
# Changes made manually in the web browser will be automatically overwritten on the next Puppet
# run.
#
# == Parameters
#
# [*url*]
#   Type: String/URL
#   Default: None - Required parameter.
#
#   The URL, formatted as your.url:port, of the smart proxy.
#
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
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
define foreman::smart_proxy(
  $url,
  $admin_user     = $::foreman::admin_user,
  $admin_password = $::foreman::admin_password,
  $host           = $::foreman::server
){
  include '::foreman'

  foreman_smart_proxy { $name:
    admin_user     => $admin_user,
    admin_password => $admin_password,
    host           => $host,
    url            => $url
  }
}
