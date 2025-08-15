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
#   Defaults to facts['networking']['fqdn'].
#
# [*ssl_redirect*]
#   (Optional) Enable SSL Redirect
#   Defaults to 'true'.
#
# [*server_aliases*]
#   (optional) List of names which should be defined as ServerAlias directives
#   in vhost.conf.
#   Defaults to facts['networking']['fqdn'].
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
# [*ssl_cert*]
#   (required with listen_ssl) Certificate to use for SSL support.
#
# [*ssl_key*]
#   (required with listen_ssl) Private key to use for SSL support.
#
# [*ssl_ca*]
#   (required with listen_ssl) CA certificate to use for SSL support.
#
# [*ssl_verify_client*]
#   (required with ssl_ca) Set the Certificate verification level
#   for Client Authentication.
#   Defaults to undef
#
# [*wsgi_processes*]
#   (optional) Number of Horizon processes to spawn
#   Defaults to $facts['os_workers']
#
# [*wsgi_threads*]
#   (optional) Number of thread to run in a Horizon process
#   Defaults to '1'
#
# [*custom_wsgi_process_options*]
#   (optional) gives you the opportunity to add custom process options or to
#   overwrite the default options for the WSGI main process.
#   eg. to use a virtual python environment for the WSGI process
#   you could set it to:
#   { python-path => '/my/python/virtualenv' }
#   Defaults to {}
#
# [*priority*]
#   (optional) The apache vhost priority.
#   Defaults to 15. To set Horizon as the primary vhost, change to 10.
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
# [*ssl_extra_params*]
#   (optional) A hash of extra parameters for apache::wsgi class. This is used
#   for SSL vhost and overrides $extra_params.
#   Defaults to undef
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
#    (optional) The base URL used to construct horizon web addresses.
#    Defaults to '/dashboard' or '/horizon' depending OS
#
#  [*root_path*]
#    (optional) The path to the location of static assets.
#    Defaults to "${horizon::params::static_path}/openstack-dashboard"
#
#  [*access_log_format*]
#    (optional) The log format to use to the access log.
#    Defaults to undef
#
#  [*access_log_file*]
#    (optional) The log file name for the virtualhost.
#    Defaults to 'horizon_access.log'
#
#  [*error_log_file*]
#    (optional) The error log file name for the virtualhost.
#    Defaults to 'horizon_error.log'
#
#  [*ssl_access_log_file*]
#    (optional) The log file name for the ssl virtualhost.
#    Defaults to 'horizon_ssl_access.log'
#
#  [*ssl_error_log_file*]
#    (optional) The error log file name for the ssl virtualhost.
#    Defaults to 'horizon_ssl_error.log'
#
class horizon::wsgi::apache (
  $bind_address                            = undef,
  $servername                              = $facts['networking']['fqdn'],
  $server_aliases                          = $facts['networking']['fqdn'],
  Boolean $listen_ssl                      = false,
  $http_port                               = 80,
  $https_port                              = 443,
  Boolean $ssl_redirect                    = true,
  $ssl_cert                                = undef,
  $ssl_key                                 = undef,
  $ssl_ca                                  = undef,
  $ssl_verify_client                       = undef,
  $wsgi_processes                          = $facts['os_workers'],
  $wsgi_threads                            = '1',
  $custom_wsgi_process_options             = {},
  $priority                                = 15,
  $vhost_conf_name                         = 'horizon_vhost',
  $vhost_ssl_conf_name                     = 'horizon_ssl_vhost',
  $extra_params                            = {},
  $ssl_extra_params                        = undef,
  Enum['temp', 'permanent'] $redirect_type = 'permanent',
  $root_url                                = $horizon::params::root_url,
  $root_path                               = "${horizon::params::static_path}/openstack-dashboard",
  $access_log_format                       = undef,
  $access_log_file                         = 'horizon_access.log',
  $error_log_file                          = 'horizon_error.log',
  $ssl_access_log_file                     = 'horizon_ssl_access.log',
  $ssl_error_log_file                      = 'horizon_ssl_error.log',
) inherits horizon::params {

  include horizon::deps
  include apache

  # We already use apache::vhost to generate our own
  # configuration file, let's clean the configuration
  # embedded within the package
  file { $horizon::params::httpd_config_file:
    ensure  => file,
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
    $ensure_ssl_vhost = 'present'

    if $ssl_cert == undef {
      fail('The ssl_cert parameter is required when listen_ssl is true')
    }

    if $ssl_key == undef {
      fail('The ssl_key parameter is required when listen_ssl is true')
    }

    if ($ssl_ca != undef and $ssl_verify_client == undef) {
      fail('The ssl_verify_client parameter is required when setting ssl_ca')
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
        $redirect_match = "^${horizon::params::root_url}\$"
        $redirect_url   = '/'
      }
      default: {
        $ensure_ssl_vhost = 'absent'
        $redirect_match = '^/$'
        $redirect_url   = $root_url_real
      }
    }
  }

  Anchor['horizon::install::end'] -> Package['httpd']

  $unix_user  = $horizon::params::wsgi_user
  $unix_group = $horizon::params::wsgi_group

  file { $horizon::params::logdir:
    ensure  => directory,
    owner   => $unix_user,
    group   => $unix_group,
    before  => Service['httpd'],
    mode    => '0750',
    require => Anchor['horizon::config::begin'],
  }

  file { "${horizon::params::logdir}/horizon.log":
    ensure  => file,
    owner   => $unix_user,
    group   => $unix_group,
    before  => Service['httpd'],
    mode    => '0640',
    require => File[$horizon::params::logdir],
  }

  $script_url = $root_url_real ? {
    ''      => '/',
    default => $root_url_real,
  }

  $wsgi_daemon_process_options = stdlib::merge(
    {
      processes    => $wsgi_processes,
      threads      => $wsgi_threads,
      user         => $unix_user,
      group        => $unix_group,
      display-name => 'horizon',
    },
    $custom_wsgi_process_options
  )

  $default_vhost_conf = {
    ip                     => $bind_address,
    servername             => $servername,
    serveraliases          => any2array($server_aliases),
    docroot                => '/var/www/',
    access_log_file        => $access_log_file,
    access_log_format      => $access_log_format,
    error_log_file         => $error_log_file,
    priority               => $priority,
    aliases                => [{
      alias => "${root_url_real}/static",
      path  => "${root_path}/static",
    }],
    port                   => $http_port,
    ssl_cert               => $ssl_cert,
    ssl_key                => $ssl_key,
    ssl_ca                 => $ssl_ca,
    ssl_verify_client      => $ssl_verify_client,
    wsgi_script_aliases    => Hash([$script_url, $horizon::params::django_wsgi]),
    wsgi_import_script     => $horizon::params::django_wsgi,
    wsgi_process_group     => $horizon::params::wsgi_group,
    wsgi_application_group => $horizon::params::wsgi_application_group,
    redirectmatch_status   => $redirect_type,
    options                => ['-Indexes', '+FollowSymLinks','+MultiViews'],
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

  ensure_resource('apache::vhost', $vhost_conf_name, stdlib::merge(
    $default_vhost_conf,
    $extra_params,
    {
      wsgi_daemon_process => Hash([$horizon::params::wsgi_group, $wsgi_daemon_process_options])
    },
    {
      redirectmatch_regexp => $redirectmatch_regexp_real,
      redirectmatch_dest   => $redirectmatch_url_real,
    }
  ))


  $ssl_extra_params_real = pick_default($ssl_extra_params, $extra_params)
  ensure_resource('apache::vhost', $vhost_ssl_conf_name, stdlib::merge(
    $default_vhost_conf,
    $ssl_extra_params_real,
    {
      wsgi_daemon_process => Hash(['horizon-ssl', $wsgi_daemon_process_options]),
    },
    {
      access_log_file      => $ssl_access_log_file,
      error_log_file       => $ssl_error_log_file,
      priority             => $priority,
      ssl                  => true,
      port                 => $https_port,
      ensure               => $ensure_ssl_vhost,
      wsgi_process_group   => 'horizon-ssl',
      redirectmatch_regexp => $root_url_real ? { '' => undef, '/' => undef, default => '^/$' },
      redirectmatch_dest   => $root_url_real ? { '' => undef, '/' => undef, default => $root_url_real },
    }
  ))

}
