# == Class: foreman::service
#
# The Foreman service
#
# == Authors
#
# Kendall Moore <kmoore@keywcorp.com>
#
class foreman::service {
  assert_private()

  service { 'foreman':
    ensure  => 'running',
    enable  => true,
    require => [
      Class['::foreman::install'],
      Class['::foreman::database']
    ],
    notify  => Service['httpd']
  }

  Class['::foreman::service'] ~> Service['httpd']
}
