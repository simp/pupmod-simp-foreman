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

  $_safe_name = regsubst($name,':|\/','__')
  $_lock_file = "${::foreman::passenger_app_root}/tmp/.rake_${_safe_name}.lock"

  exec { "foreman-rake-${name}":
    command     => "/usr/sbin/foreman-rake ${name} && /bin/touch ${_lock_file}",
    user        => $::foreman::database::db_user,
    environment => sort(join_keys_to_values(merge({'HOME' => $::foreman::passenger_app_root}, $env), '=')),
    logoutput   => 'on_failure',
    creates     => $_lock_file
  }
}
