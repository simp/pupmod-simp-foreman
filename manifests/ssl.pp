# == Class: foreman::ssl
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
class foreman::ssl (
  $access_log              = '/var/log/httpd/foreman-ssl-access.log',
  $error_log               = '/var/log/httpd/foreman-ssl-error.log',
  $passenger_app_root      = $::foreman::passenger_app_root,
  $passenger_ruby          = $::foreman::passenger_ruby,
  $server                  = $::foreman::server,
  $sslcacertificatefile    = '/etc/httpd/conf/pki/cacerts/cacerts.pem',
  $sslcacertificatepath    = $::apache::ssl::sslcacertificatepath,
  $sslcertificatechainfile = '/etc/httpd/conf/pki/cacerts/cacerts.pem',
  $sslcertificatefile      = $::apache::ssl::sslcertificatefile,
  $sslcertificatekeyfile   = $::apache::ssl::sslcertificatekeyfile,
  $sslverifyclient         = $::apache::ssl::sslverifyclient,
  $sslverifydepth          = $::apache::ssl::sslverifydepth,
  $vhost_root              = $::foreman::vhost_root
){
  include '::foreman'
  include 'apache::ssl'

  apache::add_site { '05-foreman-ssl':
    content => template('foreman/etc/httpd/conf.d/05-foreman-ssl.conf.erb')
  }

  file { '/etc/httpd/conf.d/05-foreman-ssl.d':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'apache',
    mode    => '0750',
    require => Package['httpd']
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
}
