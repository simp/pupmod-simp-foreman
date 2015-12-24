# == Define: foreman::add_auth_source
#
# Adds an authentication source to the Foreman database for web based
# authentication. Currently, only LDAP is a valid authentication
# source.
#
# NOTE: Setting authentication sources in Puppet will take precedence
# over all changes made in the web browser. Changes made manually in
# the web browser will be automatically overwritten on the next Puppet
# run.
#
# == Parameters
#
# [*ldap_server*]
# [*port*]
# [*account*]
# [*account_password*]
# [*base_dn*]
# [*attr_login*]
# [*attr_firstname*]
# [*attr_lastname*]
# [*attr_mail*]
# [*onthefly_register*]
# [*tls*]
# [*ldap_filter*]
# [*attr_photo*]
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
define foreman::auth_source(
  $ldap_server,
  $port              = '636',
  $account           = hiera('ldap::bind_dn'),
  $account_password  = hiera('ldap::bind_pw'),
  $base_dn           = hiera('ldap::base_dn'),
  $attr_login        = 'uid',
  $attr_firstname    = 'givenName',
  $attr_lastname     = 'sn',
  $attr_mail         = 'email',
  $onthefly_register = false,
  $tls               = true,
  $ldap_filter       = '',
  $attr_photo         = '',
  $groups_base_dn    = inline_template('ou=Group,<%= scope.function_hiera(["ldap::base_dn"]) %>')
) {
  unless defined('$::foreman::admin_user') {
    fail("Error: You must include '::foreman' prior to using 'foreman::auth_source'")
  }

  $admin_user     = $::foreman::admin_user
  $admin_password = $::foreman::admin_password
  $host           = $::foreman::server

  foreman_auth_source { $name:
    admin_user        => $admin_user,
    admin_password    => $admin_password,
    host              => $host,
    ldap_server       => $ldap_server,
    port              => $port,
    account           => $account,
    account_password  => $account_password,
    base_dn           => $base_dn,
    groups_base       => $groups_base_dn,
    attr_login        => $attr_login,
    attr_firstname    => $attr_firstname,
    attr_lastname     => $attr_lastname,
    attr_mail         => $attr_mail,
    onthefly_register => $onthefly_register,
    tls               => $tls,
    ldap_filter       => $ldap_filter,
    attr_photo        => $attr_photo
  }
}
