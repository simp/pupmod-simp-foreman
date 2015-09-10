# == Class: foreman::proxy::facts
#
#  A class for managing the facts portion of the Foreman smart proxy.
#
# == Parameters
#
# [*enabled*]
#   Type: Boolean
#   Default: False
#
#   Whether or not to enable facts management.
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
class foreman::proxy::facts (
  $enabled = true
){

  include '::foreman::proxy'

  file { "${::foreman::proxy::settings_directory}/facts.yml":
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0640',
    content => template('foreman/etc/foreman-proxy/settings.d/facts.yml.erb'),
    notify  => Service['foreman-proxy']
  }

  validate_bool($enabled)
}
