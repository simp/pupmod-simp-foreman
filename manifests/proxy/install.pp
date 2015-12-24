# == Class: foreman::proxy::install
#
# Install The Foreman Proxy
#
# == Parameters
class foreman::proxy::install (
  $ensure = 'latest'
) {

  assert_private()

  validate_array_member($ensure,['latest','installed'])

  package { 'foreman-proxy': ensure => $ensure }
}
