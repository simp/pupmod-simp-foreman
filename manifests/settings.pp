class foreman::settings(
  $locations_enabled     = true,
  $log_level             = $::foreman::log_level,
  $login                 = true,
  $oauth_active          = false,
  $oauth_map_users       = false,
  $oauth_consumer_key    = '',
  $oauth_consumer_secret = '',
  $organizations_enabled = false,
  $require_ssl           = $::foreman::use_ssl,
  $server                = $::foreman::server,
  $unattended            = true,
  $websockets_encrypt    = true,
  $websockets_ssl_key    = '',
  $websockets_ssl_cert   = ''
){
  include '::foreman'

  file { '/etc/foreman/settings.yaml':
    ensure  => 'present',
    owner   => 'root',
    group   => 'foreman',
    mode    => '0640',
    content => template('foreman/etc/foreman/settings.yml.erb'),
    notify  => Service['foreman']
  }
}
