# == Class: horizon::wsgi::apache
#
# Configures Apache WSGI for Horizon.
#
# === Parameters
#
# [*bind_address*]
#   (optional) Bind address in Apache for Horizon. (Defaults to '0.0.0.0')
#
# [*servername*]
#   (Optional) Server Name
#   Defaults to ::fqdn.
#
# [*ssl_redirect*]
#   (Optional) Enable SSL Redirect
#   Defaults to 'true'.
#
# [*server_aliases*]
#   (optional) List of names which should be defined as ServerAlias directives
#   in vhost.conf.
#   Defaults to ::fqdn.
#
# [*listen_ssl*]
#   (optional) Enable SSL support in Apache. (Defaults to false)
#
# [*http_port*]
#   (optional) Port to use for the HTTP virtual host. (Defaults to 80)
#
# [*https_port*]
#   (optional) Port to use for the HTTPS virtual host. (Defaults to 443)
#
# [*horizon_cert*]
#   (required with listen_ssl) Certificate to use for SSL support.
#
# [*horizon_key*]
#   (required with listen_ssl) Private key to use for SSL support.
#
# [*horizon_ca*]
#   (required with listen_ssl) CA certificate to use for SSL support.
#
# [*wsgi_processes*]
#   (optional) Number of Horizon processes to spawn
#   Defaults to $::os_workers
#
# [*wsgi_threads*]
#   (optional) Number of thread to run in a Horizon process
#   Defaults to '1'
#
# [*custom_wsgi_process_options*]
#   (optional) gives you the oportunity to add custom process options or to
#   overwrite the default options for the WSGI main process.
#   eg. to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
#
# [*priority*]
#   (optional) The apache vhost priority.
#   Defaults to '15'. To set Horizon as the primary vhost, change to '10'.
#
# [*vhost_conf_name*]
#   (Optional) Description
#   Defaults to 'horizon_vhost'.
#
# [*vhost_ssl_conf_name*]
#   (Optional) Description
#   Defaults to 'horizon_ssl_vhost'.
#
# [*extra_params*]
#   (optional) A hash of extra parameters for apache::wsgi class.
#   Defaults to {}
#
# [*redirect_type*]
#   (optional) What type of redirect to use when redirecting an http request
#   for a user. This should be either 'temp' or 'permanent'. Setting this value
#   to 'permanent' will result in the use of a 301 redirect which may be cached
#   by a user's browser.  Setting this value to 'temp' will result in the use
#   of a 302 redirect which is not cached by browsers and may solve issues if
#   users report errors accessing horizon.
#   Defaults to 'permanent'
#
#  [*root_url*]
#    (optional) The base URL used to contruct horizon web addresses.
#    Defaults to '/dashboard' or '/horizon' depending OS
#
#  [*root_path*]
#    (optional) The path to the location of static assets.
#    Defaults to "${::horizon::params::static_path}/openstack-dashboard"
#
#  [*access_log_format*]
#    (optional) The log format to use to the access log.
#    Defaults to false
#
class horizon::wsgi::apache (
  $bind_address                = undef,
  $servername                  = $::fqdn,
  $server_aliases              = $::fqdn,
  $listen_ssl                  = false,
  $http_port                   = 80,
  $https_port                  = 443,
  $ssl_redirect                = true,
  $horizon_cert                = undef,
  $horizon_key                 = undef,
  $horizon_ca                  = undef,
  $wsgi_processes              = $::os_workers,
  $wsgi_threads                = '1',
  $custom_wsgi_process_options = {},
  $priority                    = '15',
  $vhost_conf_name             = 'horizon_vhost',
  $vhost_ssl_conf_name         = 'horizon_ssl_vhost',
  $extra_params                = {},
  $redirect_type               = 'permanent',
  $root_url                    = $::horizon::params::root_url,
  $root_path                   = "${::horizon::params::static_path}/openstack-dashboard",
  $access_log_format           = false,
) inherits horizon::params {

  include horizon::deps
  include apache
  include apache::mod::wsgi

  # We already use apache::vhost to generate our own
  # configuration file, let's clean the configuration
  # embedded within the package
  file { $::horizon::params::httpd_config_file:
    ensure  => present,
    content => "#
# This file has been cleaned by Puppet.
#
# OpenStack Horizon configuration has been moved to:
# - ${priority}-${vhost_conf_name}.conf
# - ${priority}-${vhost_ssl_conf_name}.conf
#",
    require => Anchor['horizon::config::begin'],
  }

  # NOTE(tobasco): If root_url is set to '/' the paths in the apache
  # configuration will be wrong (double slashes) so we fix that here.
  if $root_url == '/' {
    $root_url_real = ''
  } else {
    $root_url_real = $root_url
  }

  if $listen_ssl {
    include apache::mod::ssl
    $ensure_ssl_vhost = 'present'

    if $horizon_cert == undef {
      fail('The horizon_cert parameter is required when listen_ssl is true')
    }

    if $horizon_key == undef {
      fail('The horizon_key parameter is required when listen_ssl is true')
    }

    if $ssl_redirect {
      $redirect_match = '(.*)'
      $redirect_url   = "https://${servername}"
    } else {
      $redirect_match = '^/$'
      $redirect_url = $root_url_real
    }
  } else {
    case $root_url_real {
      '': {
        $ensure_ssl_vhost = 'absent'
        $redirect_match = "^${::horizon::params::root_url}\$"
        $redirect_url   = '/'
      }
      default: {
        $ensure_ssl_vhost = 'absent'
        $redirect_match = '^/$'
        $redirect_url   = $root_url_real
      }
    }
  }

  if !($redirect_type in ['temp', 'permanent']) {
    fail("Invalid redirect type '${redirect_type} provided.")
  }

  Package['horizon'] -> Package['httpd']
  Concat[$::horizon::params::config_file] ~> Service['httpd']

  $unix_user  = $::horizon::params::wsgi_user
  $unix_group = $::horizon::params::wsgi_group

  file { $::horizon::params::logdir:
    ensure  => directory,
    owner   => $unix_user,
    group   => $unix_group,
    before  => Service['httpd'],
    mode    => '0751',
    require => Anchor['horizon::config::begin'],
  }

  file { "${::horizon::params::logdir}/horizon.log":
    ensure  => file,
    owner   => $unix_user,
    group   => $unix_group,
    before  => Service['httpd'],
    mode    => '0640',
    require => File[$::horizon::params::logdir],
  }

  $script_url = $root_url_real ? {
    ''      => '/',
    default => $root_url_real,
  }

  $wsgi_daemon_process_options = merge(
    {
      processes    => $wsgi_processes,
      threads      => $wsgi_threads,
      user         => $unix_user,
      group        => $unix_group,
      display-name => 'horizon',
    },
    $custom_wsgi_process_options
  )

  $default_vhost_conf_no_ip = {
    servername                  => $servername,
    serveraliases               => any2array($server_aliases),
    docroot                     => '/var/www/',
    access_log_file             => 'horizon_access.log',
    access_log_format           => $access_log_format,
    error_log_file              => 'horizon_error.log',
    priority                    => $priority,
    aliases                     => [{
      alias => "${root_url_real}/static",
      path  => "${root_path}/static",
    }],
    port                        => $http_port,
    ssl_cert                    => $horizon_cert,
    ssl_key                     => $horizon_key,
    ssl_ca                      => $horizon_ca,
    wsgi_script_aliases         => hash([$script_url, $::horizon::params::django_wsgi]),
    wsgi_daemon_process         => $::horizon::params::wsgi_group,
    wsgi_daemon_process_options => $wsgi_daemon_process_options,
    wsgi_import_script          => $::horizon::params::django_wsgi,
    wsgi_process_group          => $::horizon::params::wsgi_group,
    wsgi_application_group      => $::horizon::params::wsgi_application_group,
    redirectmatch_status        => $redirect_type,
  }

  # Only add the 'ip' element to the $default_vhost_conf hash if it was explicitly
  # specified in the instantiation of the class.  This is because ip => undef gets
  # changed to ip => '' via the Puppet function API when ensure_resource is called.
  # See https://bugs.launchpad.net/puppet-horizon/+bug/1371345
  if $bind_address {
    $default_vhost_conf = merge($default_vhost_conf_no_ip, { ip => $bind_address })
  } else {
    $default_vhost_conf = $default_vhost_conf_no_ip
  }

  if $listen_ssl and $ssl_redirect {
    # If we run SSL and has enabled ssl redirect we should always force https
    # no matter what the root url is.
    $redirectmatch_regexp_real = $redirect_match
    $redirectmatch_url_real = $redirect_url
  } else {
    $redirectmatch_regexp_real = $root_url_real ? { '' => undef, '/' => undef, default => $redirect_match }
    $redirectmatch_url_real = $root_url_real ? { '' => undef, '/' => undef, default => $redirect_url }
  }

  ensure_resource('apache::vhost', $vhost_conf_name, merge ($default_vhost_conf, $extra_params, {
    redirectmatch_regexp => $redirectmatch_regexp_real,
    redirectmatch_dest   => $redirectmatch_url_real,
  }))
  ensure_resource('apache::vhost', $vhost_ssl_conf_name, merge ($default_vhost_conf, $extra_params, {
    access_log_file      => 'horizon_ssl_access.log',
    error_log_file       => 'horizon_ssl_error.log',
    priority             => $priority,
    ssl                  => true,
    port                 => $https_port,
    ensure               => $ensure_ssl_vhost,
    wsgi_daemon_process  => 'horizon-ssl',
    wsgi_process_group   => 'horizon-ssl',
    redirectmatch_regexp => $root_url_real ? { '' => undef, '/' => undef, default => '^/$' },
    redirectmatch_dest   => $root_url_real ? { '' => undef, '/' => undef, default => $root_url_real },
  }))

}
