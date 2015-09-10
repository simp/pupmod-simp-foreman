# == Class: foreman::proxy::puppetca
#
# A class for managing the Puppet CA portion of the Foreman smart proxy.
#
# == Parameters
#
# [*enabled*]
#   Type: Boolean
#   Default: True
#
#   Whether or not to enable the Puppet CA portion of the Foreman
#   smart proxy.
#
# [*puppet_dir*]
#   Type: Directory/Absolute Path/String
#   Default: /etc/puppet
#
#   The main Puppet directory.
#
# [*ssl_dir*]
#   Type: Directory/Absolute Path/String
#   Default: /var/lib/puppet/ssl
#
#   The directory where Puppet certificates are stored.
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
class foreman::proxy::puppetca (
  $enabled    = true,
  $puppet_dir = $::foreman::proxy::puppet_dir,
  $ssl_dir    = $::foreman::proxy::puppet_cert_source
){
  include '::foreman::proxy'

  file { "${::foreman::proxy::settings_directory}/puppetca.yml":
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0640',
    content => template('foreman/etc/foreman-proxy/settings.d/puppetca.yml.erb'),
    notify  => Service['foreman-proxy']
  }

  validate_absolute_path($puppet_dir)
  validate_absolute_path($ssl_dir)
  validate_bool($enabled)
}
