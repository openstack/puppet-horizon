# == Class: horizon::wsgi::apache
#
# Configures Apache WSGI for Horizon.
#
# === Parameters
#
#  [*bind_address*]
#    (optional) Bind address in Apache for Horizon. (Defaults to '0.0.0.0')
#
#  [*listen_ssl*]
#    (optional) Enable SSL support in Apache. (Defaults to false)
#
#  [*horizon_cert*]
#    (required with listen_ssl) Certificate to use for SSL support.
#
#  [*horizon_key*]
#    (required with listen_ssl) Private key to use for SSL support.
#
#  [*horizon_ca*]
#    (required with listen_ssl) CA certificate to use for SSL support.
#
#  [*wsgi_processes*]
#    (optional) Number of Horizon processes to spawn
#    Defaults to '3'
#
#  [*wsgi_threads*]
#    (optional) Number of thread to run in a Horizon process
#    Defaults to '10'
#
#  [*extra_params*]
#    (optional) A hash of extra paramaters for apache::wsgi class.
#    Defaults to {}
class horizon::wsgi::apache (
  $bind_address    = undef,
  $fqdn            = $::fqdn,
  $servername      = $::fqdn,
  $listen_ssl      = false,
  $ssl_redirect    = true,
  $horizon_cert    = undef,
  $horizon_key     = undef,
  $horizon_ca      = undef,
  $wsgi_processes  = '3',
  $wsgi_threads    = '10',
  $extra_params    = {},
) {

  include ::horizon::params
  include ::apache
  include ::apache::mod::wsgi

  # We already use apache::vhost to generate our own
  # configuration file, let's remove the configuration
  # embedded within the package
  file { $::horizon::params::httpd_config_file:
    ensure => absent
  }


  if $listen_ssl {
    include ::apache::mod::ssl
    $ensure_ssl_vhost = 'present'

    if $horizon_ca == undef {
      fail('The horizon_ca parameter is required when listen_ssl is true')
    }

    if $horizon_cert == undef {
      fail('The horizon_cert parameter is required when listen_ssl is true')
    }

    if $horizon_key == undef {
      fail('The horizon_key parameter is required when listen_ssl is true')
    }

    if $ssl_redirect {
      $redirect_match = '(.*)'
      $redirect_url   = "https://${servername}"
    }

  } else {
    $ensure_ssl_vhost = 'absent'
    $redirect_match = '^/$'
    $redirect_url   = $::horizon::params::root_url
  }

  Package['horizon'] -> Package[$::horizon::params::http_service]
  File[$::horizon::params::config_file] ~> Service[$::horizon::params::http_service]

  file { $::horizon::params::logdir:
    ensure  => directory,
    owner   => $::horizon::params::wsgi_user,
    group   => $::horizon::params::wsgi_group,
    before  => Service[$::horizon::params::http_service],
    mode    => '0751',
    require => Package['horizon']
  }

  file { "${::horizon::params::logdir}/horizon.log":
    ensure  => file,
    owner   => $::horizon::params::wsgi_user,
    group   => $::horizon::params::wsgi_group,
    before  => Service[$::horizon::params::http_service],
    mode    => '0640',
    require => [ File[$::horizon::params::logdir], Package['horizon'] ],
  }

  $default_vhost_conf = {
    ip                   => $bind_address,
    servername           => $servername,
    serveraliases        => any2array($fqdn),
    docroot              => '/var/www/',
    access_log_file      => 'horizon_access.log',
    error_log_file       => 'horizon_error.log',
    priority             => '15',
    aliases              => [
      { alias => '/static', path => '/usr/share/openstack-dashboard/static' }
    ],
    port                 => 80,
    ssl_cert             => $horizon_cert,
    ssl_key              => $horizon_key,
    ssl_ca               => $horizon_ca,
    wsgi_script_aliases  => hash([$::horizon::params::root_url, $::horizon::params::django_wsgi]),
    wsgi_daemon_process  => 'horizon',
    wsgi_daemon_process_options => {
      processes    => $wsgi_processes,
      threads      => $wsgi_threads,
      user         => $::horizon::params::wsgi_user,
      group        => $::horizon::params::wsgi_group,
    },
    wsgi_import_script   => $::horizon::params::django_wsgi,
    wsgi_process_group   => $::horizon::params::wsgi_group,
    redirectmatch_status => 'permanent',
  }

  ensure_resource('apache::vhost', 'horizon_vhost', merge ($default_vhost_conf, $extra_params, {
    redirectmatch_regexp => $redirect_match,
    redirectmatch_dest   => $redirect_url,
  }))
  ensure_resource('apache::vhost', 'horizon_ssl_vhost',merge ($default_vhost_conf, $extra_params, {
    access_log_file      => 'horizon_ssl_access.log',
    error_log_file       => 'horizon_ssl_error.log',
    priority             => '15',
    ssl                  => true,
    port                 => 443,
    ensure               => $ensure_ssl_vhost,
    wsgi_daemon_process  => 'horizon-ssl',
    redirectmatch_regexp => '^/$',
    redirectmatch_dest   => $::horizon::params::root_url,
  }))

}
