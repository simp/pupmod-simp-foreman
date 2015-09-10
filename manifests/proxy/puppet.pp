# == Class: foreman::proxy::puppet
#
# A class for managing the puppet agent portion of the Foreman smart proxy.
#
# == Parameters
#
# [*customrun_args*]
#   Type: String
#   Default: '-ay -f -s'
#
#   Any arguments to be passed to the custom run script. The hostname
#   of the system to run against will be appended after the custom
#   commands.
#
# [*customrun_cmd*]
#   Type: String/Absolute Path/Executable
#   Default: /bin/false
#
#   The full path of the script you want to run in place of the
#   default, /bin/false
#
# [*enabled*]
#   Type: Boolean
#   Default: True
#
#   Whether or not to enable puppet agent control inside of the
#   Foreman sart proxy.
#
# [*puppet_conf*]
#   Type: String/Absolute Path
#   Default: /etc/puppet/puppet.conf
#
#   The location of the puppet configuration file.
#
# [*puppet_provider*]
#   Type: String
#   Default: customrun (leaving blank also defaults to this)
#
#   Which tool will provide the ability to run the puppet agent. Valid
#   options are:
#     - puppetrun (for puppetrun/kick, deprecated in Puppet 3)
#     - mcollective (uses mco puppet)
#     - puppetssh (run puppet over SSH)
#     - salt (uses salt puppet.run)
#     - customrun (calls a custom command with args)
#
# [*puppet_ssl_ca*]
#   Type: Certificate File/Absolute Path
#   Default: /var/lib/puppet/ssl/certs/ca.pem
#
#   The Puppet CA file.
#
# [*puppet_ssl_cert*]
#   Type: Certificate File/Absolute Path
#   Default: /var/lib/puppet/ssl/certs/<fqdn>.pem
#
#   The SSL certificate for the puppet master.
#
# [*puppet_ssl_key*]
#   Type: Certificate File/Absolute Path
#   Default: /var/lib/puppet/ssl/private_keys/<fqdn>.pem
#
#   The private key for the puppet master.
#
# [*puppet_url*]
#   Type: URL/String
#   Default: https://<fqdn_puppetmaster>:8140
#
#   The URL of the puppet master for API requests.
#
# [*puppet_use_environment_api*]
#   Type: Boolean
#   Default: false
#
#   Whether or not to override the use of Puppet's API to list
#   environemnts. By default it will use only if environmentpath is
#   given in puppet.conf, else it will look for environemnts in
#   puppet.conf.
#
# [*puppet_user*]
#   Type: User/String
#   Default: ''
#
#   Which user to invoke sudo as to run puppet commands.
#
# [*puppetssh_command*]
#   Type: String/Command
#   Default: '/usr/bin/puppet agent --onetime --no-usecacheonfailure'
#
#   The command which will be sent to the host.
#
# [*puppetssh_keyfile*]
#   Type: Certificate File/Absolute Path/String
#   Default: ''
#
# [*puppetssh_sudo*]
#   Type: Boolean
#   Default: False
#
#   Whether or not to use sudo before the SSH command.
#
# [*puppetssh_user*]
#   Type: Username/String
#   Default: ''
#
#   Which user should the proxy connect.
#
# [*puppetssh_wait*]
#   Type: Boolean
#   Default: False
#
#   Whether or not to wait for the command to finish (and capture the
#   exit code), or detach process and return 0.
#   NOTE: Enabling this option causes the Foreman web UI to be blocked
#   when executing puppetrun with timeout from the Browser and/or
#   Foreman's REST client after 60 seconds.
#
# == Authors
#
# * Kendall Moore <kmoore@keywcorp.com>
#
class foreman::proxy::puppet (
  $customrun_args             = '-ay -f -s',
  $customrun_cmd              = '/bin/false',
  $enabled                    = true,
  $puppet_conf                = "${::foreman::proxy::puppet_dir}/puppet.conf",
  $puppet_provider             = '',
  $puppet_url                 = "https://${::fqdn}:8140",
  $puppet_use_environment_api = false,
  $puppet_user                = '',
  $puppetssh_command          = '/usr/bin/puppet agent --onetime --no-usecacheonfailure',
  $puppetssh_keyfile          = '',
  $puppetssh_sudo             = false,
  $puppetssh_user             = '',
  $puppetssh_wait             = false
){

  include '::foreman::proxy'

  file { "${::foreman::proxy::settings_directory}/puppet.yml":
    owner   => 'root',
    group   => 'foreman-proxy',
    mode    => '0640',
    content => template('foreman/etc/foreman-proxy/settings.d/puppet.yml.erb'),
    notify  => Service['foreman-proxy']
  }

  validate_absolute_path($customrun_cmd)
  validate_absolute_path($puppet_conf)
  if !empty($puppetssh_keyfile) {
    validate_absolute_path($puppetssh_keyfile)
  }
  if !empty($puppet_provider) {
    validate_array_member(['puppetrun','mcollective','puppetssh','salt','customrun'], $puppet_provider)
  }
  validate_bool($enabled)
  validate_bool($puppet_use_environment_api)
  validate_bool($puppetssh_sudo)
  validate_bool($puppetssh_wait)
}
