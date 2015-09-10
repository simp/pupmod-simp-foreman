# == Class foreman::proxy
#
# A class for managing the Foreman proxy. By default, sets up a
# basic proxy which includes monitoring, reports, and the
# ability to control the Puppet Agent and Puppet CA.
#
# TODO: Add ability to enable/manage DNS, DHCP, TFTP, etc.
#
# == Parameters
#
# [*cert_source*]
#   Type: Absolute Path/String
#   Default: /var/lib/puppet/ssl
#
#   The source of the Puppet SSL directory. This is used to copy the
#   Puppet SSL certs into the foreman space.
#
# [*daemonize*]
#   Type: Boolean
#   Default: True
#
#   Whether or not to daemonize the foreman-proxy service.
#
# [*https_port*]
#   Type: Port/Integer
#   Default: 8443
#
#   The SSL port for foreman-proxy to connect to.
#
# [*log_file*]
#   Type: Absolute Path/String
#   Default: /var/log/foreman-proxy/proxy.log
#
#   The location foreman-proxy should send logs to.
#
# [*log_level*]
#   Type: String
#   Default: 'WARN'
#
#   The minimum level of logs to be sent to log_file.
#
# [*settings_directory*]
#   Type: Absolute Path/String
#   Default: /etc/foreman-proxy/settings.d
#
#   The location to store the foreman-proxy settings YAML files such as
#   DNS, DHCP, TFTP, puppet, etc.
#
# [*ssl_ca_file*]
#   Type: Certificate File/Absolute Path/String
#   Default: /var/lib/puppet/ssl/certs/ca.pem
#
#   The Puppet CA certificate file.
#
# [*ssl_certificate*]
#   Type: Certificate File/Absolute Path/String
#   Default: /var/lib/puppet/ssl/certs/<fqdn>.pem
#
#   The puppet master host certificate.
#
# [*ssl_private_key*]
#   Type: Certificate File/Absolute Path/String
#   Default: /var/lib/puppet/ssl/private_keys/<fqdn>.pem
#
#   The puppet master host private key.
#
# [*trusted_hosts*]
#   Type: Array
#   Default: ["<fqdn_fact>"]
#
# [*virsh_network*]
#   Type: String
#   Default: 'default'
#
#   TODO: Add docs on this.
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
class foreman::proxy (
  $daemonize          = true,
  $ssl_dir            = '/etc/foreman-proxy/ssl',
  $https_port         = '8415',
  $log_file           = '/var/log/foreman-proxy/proxy.log',
  $log_level          = 'WARN',
  $proxy_domain       = $::domain,
  $proxy_hostname     = $::hostname,
  $proxy_port         = '8415',
  $puppet_cert_source = "${::puppet_vardir}/ssl",
  $puppet_dir         = '/etc/puppet',
  $settings_directory = '/etc/foreman-proxy/settings.d',
  $trusted_hosts      = hiera_array('foreman::proxy::trusted_hosts', [$::fqdn]),
  $virsh_network      = 'default'
){
  include '::foreman'

  package { 'foreman-proxy':
    ensure => 'latest'
  }

  file { $settings_directory:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0750',
    require => Package['foreman-proxy'],
    notify  => Service['foreman-proxy']
  }

  file { '/etc/foreman-proxy/settings.yml':
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0640',
    content => template('foreman/etc/foreman-proxy/settings.yml.erb'),
    require => File[$settings_directory],
    notify  => Service['foreman-proxy']
  }

  file { "${settings_directory}/foreman_proxy.yml":
    ensure  => 'symlink',
    target  => '/etc/foreman-proxy/settings.yml',
    require => File['/etc/foreman-proxy/settings.yml'],
    notify  => Service['foreman-proxy']
  }

#  if $::foreman::use_simp_pki {
#    include 'pki'
#
#    ::pki::copy { '/etc/foreman-proxy':
#      group  => 'foreman-proxy',
#      notify => Service['foreman-proxy']
#    }
#  }
#  elsif !empty($::foreman::host_cert_source) {
#    file { '/etc/foreman-proxy/pki':
#      ensure => 'directory',
#      owner  => 'root',
#      group  => 'foreman-proxy',
#      mode   => '0640',
#      source => $::foreman::host_cert_source,
#      notify => Service['foreman-proxy']
#    }
#  }

  file { $ssl_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'foreman-proxy',
    mode   => '0750',
    notify => Service['foreman-proxy']
  }

  file { "${ssl_dir}/certs":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0775',
    require => File[$ssl_dir],
    notify  => Service['foreman-proxy']
  }

  file { "${ssl_dir}/private_keys":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0750',
    require => File[$ssl_dir],
    notify  => Service['foreman-proxy']
  }

  file { "${ssl_dir}/certs/ca.pem":
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0664',
    source  => "${puppet_cert_source}/certs/ca.pem",
    require => File[$ssl_dir],
    notify  => Service['foreman-proxy']
  }

  file { "${ssl_dir}/certs/${::fqdn}.pem":
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0660',
    source  => "${puppet_cert_source}/certs/${::fqdn}.pem",
    require => File[$ssl_dir],
    notify  => Service['foreman-proxy']
  }

  file { "${ssl_dir}/private_keys/${::fqdn}.pem":
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0640',
    source  => "${puppet_cert_source}/private_keys/${::fqdn}.pem",
    require => File[$ssl_dir],
    notify  => Service['foreman-proxy']
  }

  include '::foreman::proxy::facts'
  include '::foreman::proxy::puppetca'
  include '::foreman::proxy::puppet'

  service { 'foreman-proxy':
    ensure  => 'running',
    require => Package['foreman-proxy']
  }

  if $::foreman::use_ssl {
    $l_url = "https://${proxy_hostname}.${proxy_domain}:${proxy_port}"
  } else {
    $l_url = "http://${proxy_hostname}.${proxy_domain}:${proxy_port}"
  }

  foreman::smart_proxy { $proxy_hostname:
    url    => $l_url,
  }

  validate_absolute_path($puppet_cert_source)
  validate_bool($daemonize)
  validate_port($https_port)
  validate_absolute_path($log_file)
  validate_array_member($log_level,['DEBUG','INFO','WARN','ERROR','FATAL'])
  validate_absolute_path($puppet_dir)
  validate_absolute_path($settings_directory)
  validate_net_list($trusted_hosts)
}
