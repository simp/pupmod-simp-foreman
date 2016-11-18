# == Class: foreman::config::ssl
#
# A class for managing the SSL portion of the Foreman web UI. This
# class uses the SIMP Apache module to add an apache config to
# /etc/httpd/conf.d for all of the Foreman's SSL settings.
#
# == Parameters
#
# [*access_log*]
#   Type: Absolute Path/String
#   Default: /var/log/httpd/foreman-ssl-access.log
#
#   The Apache SSL access log for the Foreman web UI.
#
# [*error_log*]
#   Type: Absollute Path/String
#   Default: /var/log/httpd/foreman-ssl-error.log
#
#   The Apache SSL error log for the Foreman web UI.
#
# [*passenger_app_root*]
#   Type: Absolute Path/String
#   Default: /usr/share/foreman
#
#   The directory Passenger will run inside of.
#
# [*passenger_ruby*]
#   Type: Executable/String
#   Default: /usr/bin/ruby193-ruby
#
#   The ruby executable that Passenger will use.
#
# [*server*]
#   Type: Hostname/String
#   Default: <fqdn_puppetmaster>
#
#   The server that the Foreman will run on.
#
# [*sslcacertificatefile*]
# [*sslcacertificatepath*]
# [*sslcertificatechainfile*]
# [*sslcertificatefile*]
# [*sslcertificatekeyfile*]
# [*sslverifyclient*]
# [*sslverifydepth*]
#
# [*vhost_root*]
#   Type: Absolute Path/String
#   Default: /usr/share/foreman/public
#
#   The root of the Foreman SSL web interface.
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
class foreman::config::ssl (
  $access_log              = '/var/log/httpd/foreman-ssl-access.log',
  $error_log               = '/var/log/httpd/foreman-ssl-error.log',
  $passenger_app_root      = $::foreman::config::passenger_app_root,
  $passenger_ruby          = $::foreman::config::passenger_ruby,
  $server                  = $::foreman::config::server,
  $sslcacertificatefile    = '/etc/httpd/conf/pki/cacerts/cacerts.pem',
  $sslcacertificatepath    = $::simp_apache::ssl::sslcacertificatepath,
  $sslcertificatechainfile = '/etc/httpd/conf/pki/cacerts/cacerts.pem',
  $sslcertificatefile      = $::simp_apache::ssl::sslcertificatefile,
  $sslcertificatekeyfile   = $::simp_apache::ssl::sslcertificatekeyfile,
  $sslverifyclient         = $::simp_apache::ssl::sslverifyclient,
  $sslverifydepth          = $::simp_apache::ssl::sslverifydepth,
  $vhost_root              = $::foreman::config::vhost_root
) inherits ::simp_apache::ssl {
  # FIXME When this is private to the module, spec tests throw exceptions about 
  # accessing a private class.  May be problem with private class inheriting from
  # another module.
  #assert_private()

  unless defined('::simp_apache::ssl') {
    fail("Error: You must include '::simp_apache::ssl' prior to 'foreman::config::ssl'")
  }

  validate_absolute_path($access_log)
  validate_absolute_path($error_log)
  validate_absolute_path($passenger_app_root)
  validate_absolute_path($passenger_ruby)
  validate_absolute_path($sslcacertificatefile)
  validate_absolute_path($sslcacertificatepath)
  validate_absolute_path($sslcertificatefile)
  validate_absolute_path($sslcertificatekeyfile)
  validate_absolute_path($vhost_root)
  validate_array_member($sslverifyclient,['require','optional'])
  validate_integer($sslverifydepth)

  simp_apache::add_site { '05-foreman-ssl':
    content => template('foreman/etc/httpd/conf.d/05-foreman-ssl.conf.erb')
  }

  file { '/etc/httpd/conf.d/05-foreman-ssl.d':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'apache',
    mode    => '0750',
    require => Package['httpd']
  }
}
