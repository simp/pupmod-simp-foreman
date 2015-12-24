# == Class: foreman::database::install
#
# Install The Foreman Database
#
# == Parameters
class foreman::database::install (
  $ensure = 'latest'
) {

  assert_private()

  validate_array_member($ensure,['latest','installed'])

  package { 'foreman-postgresql': ensure => $ensure }
}
