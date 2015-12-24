# == Class: foreman::database
#
# == Parameters
#
# [*db_name*]
#   Type: String
#   Default: 'foreman'
#
#   The name of the Foreman database that will be created.
#
# [*db_uesr*]
#   Type: String/Username
#   Default: 'foreman'
#
#   The name of the user who will access this database.
#
# [*db_password*]
#   Type: String
#   Default: ''
#
#   The (optional) password for the Foreman database.
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
class foreman::database (
  $db_user              = 'foreman',
  $development_database = '',
  $development_password = '',
  $log_level            = 'WARN',
  $production_database  = 'foreman',
  $production_password  = '',
  $test_database        = '',
  $test_password        = ''
) {
  include '::postgresql::client'
  include '::postgresql::server'
  include '::foreman::database::install'

  file { '/etc/foreman/database.yml':
    ensure  => 'present',
    owner   => 'root',
    group   => 'foreman',
    mode    => '0640',
    content => template('foreman/etc/foreman/database.yml.erb')
  }

  $_production_password = empty($production_password) ? {
    ''      => false,
    default => postgresql_password($db_user, $production_password),
  }
  postgresql::server::db { $production_database:
    user     => $db_user,
    password => $_production_password,
    owner    => $db_user,
  }
  ~>
  foreman::rake { 'db:migrate': } ~> foreman::rake { 'db:seed': } ~> foreman::rake { 'apipie:cache': }

  if !empty($development_database) {
    $_development_password = empty($development_password) ? {
      ''      => false,
      default => postgresql_password($db_user, $development_password),
    }
    postgresql::server::db { $development_database:
      user     => $db_user,
      password => $_development_password,
      owner    => $db_user,
    }
  }

  if !empty($test_database) {
    $_test_password = empty($test_password) ? {
      ''      => false,
      default => postgresql_password($db_user, $test_password),
    }
    postgresql::server::db { $test_database:
      user     => $db_user,
      password => $_test_password,
      owner    => $db_user,
    }
  }

  Postgresql::Server::Role[$db_user] -> Postgresql::Server::Database[$production_database]
}
