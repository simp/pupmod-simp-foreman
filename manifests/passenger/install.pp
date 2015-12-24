# == Class: foreman::passenger::install
#
# Install The Foreman Passenger
#
# == Parameters
class foreman::passenger::install (
  $ensure = 'latest'
) {

  assert_private()

  validate_array_member($ensure,['latest','installed'])

  package { [
    'tfm-rubygem-passenger',
    'tfm-rubygem-passenger-native',
    'tfm-rubygem-passenger-native-libs',
    'tfm-mod_passenger'
    ]:
    ensure => $ensure
  }
}
