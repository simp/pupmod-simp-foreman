# == Define: foreman::rake
#
# Executes the foreman-rake command with the given argument (name).
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
define foreman::rake (
  $env = {}
){
  exec { "foreman-rake-${name}":
    command     => "/usr/sbin/foreman-rake ${name}",
    user        => $::foreman::database::db_user,
    environment => sort(join_keys_to_values(merge({'HOME' => $::foreman::passenger_app_root}, $env), '=')),
    logoutput   => 'on_failure',
    refreshonly => true
  }
}
