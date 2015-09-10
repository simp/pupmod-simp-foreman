# == Class: foreman::passenger
#
# Add the Passenger site to Apache
#
# Configuration items are described on
# http://www.modrails.com/documentation/Users%20guide%20Apache.html
#
# == Parameters
#
# Any variable not described here should be referenced in the Passenger
# documentation for Apache.
#
# [*ca_port*]
# Type: Integer
# Default: 8140
#
# The port that the Puppet CA process should listen on.
#
# [*master_port*]
# Type: Integer
# Default: 8140
#
# The port that the Puppet master process should listen on.
#
# If this is identical to $ca_port, then certificate validation will not be
# enforced.
#
# [*max_pool_size*]
# Type: Integer
# Default: Calculated based on the numbers on the Passenger tuning portion
#   of the modrails page. It will hover somewhere around 2 times the number
#   of processors on the system while taking memory size into account.
#
# The number of application processes that may simultaneously exist.
#
# [*min_instances*]
# Type: Integer
# Default: Half of the max_pool_size rounded up
#
# The minimum number of application processes that should exist for a given
# application.
#
# == Authors:
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
# * Kendall Moore <kmoore@keywcorp.com>
#
class foreman::passenger (
  $buffer_response = 'off',
  $friendly_error_pages = 'off',
  $high_performance = 'on',
  $httpd_base = '/usr/share/foreman',
  $master_port = '8414',
  $max_pool_size = '',
  $min_instances = '',
  $passenger_log_level = '0',
#  $passenger_module = '/usr/lib64/httpd/modules/mod_passenger.so',
  $passenger_root = '/opt/rh/ruby193/root/usr/share/gems/gems/passenger-4.0.18/lib/phusion_passenger/locations.ini',
  $passenger_module =  '/opt/rh/httpd24/root/usr/lib64/httpd/modules/mod_passenger.so',
  $passenger_ruby = $::foreman::passenger_ruby,
  $pool_idle_time = '100',
  $pre_start = true,
  $rack_auto_detect = 'on',
  $rails_auto_detect = 'on',
  $ssl_protocols = ['TLSv1','TLSv1.1','TLSv1.2'],
  $ssl_cipher_suite = hiera('openssl::cipher_suite',['HIGH']),
  $stat_throttle_rate = '120',
  $temp_dir = '/var/run/passenger',
  $use_global_queue = 'on',
  $user_switching = 'on'
){
  include '::foreman'
  include '::apache::ssl'

  package { [
    'ruby193-rubygem-passenger40',
    'ruby193-mod_passenger40'
    ]:
    ensure => 'latest',
    notify => Apache::Add_site['foreman_passenger']
  }

  file { $temp_dir :
    ensure => 'directory',
    owner => 'root',
    group => 'root',
    mode => '755',
    before => Apache::Add_site['foreman_passenger']
  }

  apache::add_site { 'foreman_passenger':
    content => template('foreman/etc/httpd/conf.d/foreman_passenger.erb'),
    notify  => Service['httpd']
  }

  # Validation
  $on_off = ['on', 'off']
  validate_array($ssl_protocols)
  validate_array($ssl_cipher_suite)
  validate_integer($master_port)
#  validate_integer($ca_port)
  validate_array_member($high_performance,['on','off'])
  validate_re($max_pool_size,'^(\d+|\s*)$')
  validate_re($stat_throttle_rate,'^(\d+|\s*)$')
  validate_integer($pool_idle_time)
  validate_integer($stat_throttle_rate)
  validate_bool($pre_start)
  validate_between($passenger_log_level,'0','3')
  validate_absolute_path($temp_dir)
  validate_absolute_path($passenger_root)
  validate_absolute_path($passenger_ruby)
  validate_absolute_path($passenger_module)
  validate_absolute_path($httpd_base)
  if $rack_auto_detect != '' and ! member($on_off, $rack_auto_detect) {
    fail("Rack_auto_detect must be one of '$on_off'")
  }
  if $high_performance != '' and ! member($on_off, $high_performance) {
    fail("High_performance must be one of '$on_off'")
  }
  if $buffer_response != '' and ! member($on_off, $buffer_response) {
    fail("Buffer_response must be one of '$on_off'")
  }
  if ! member($on_off, $user_switching) {
    fail("User_switching must be one of '$on_off'")
  }
  if ! member($on_off, $friendly_error_pages) {
    fail("Friendly_error_pages must be one of '$on_off'")
  }
}
