# == Class: foreman::install
#
# Install The Foreman
#
# == Parameters
class foreman::install (
  $ensure = 'latest'
) {

  assert_private()

  validate_array_member($ensure,['latest','installed'])

  package { 'foreman':                     ensure => $ensure }
  package { 'foreman-release':             ensure => $ensure }
  package { 'foreman-cli':                 ensure => $ensure }
  package { 'foreman-selinux':             ensure => $ensure }
  # For the custom types
  package { 'rubygem-rest-client': ensure => $ensure }
}
