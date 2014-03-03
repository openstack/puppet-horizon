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
class horizon::wsgi::apache (
  $bind_address = undef,
  $fqdn         = $::fqdn,
  $servername   = $::fqdn,
  $listen_ssl   = false,
  $ssl_redirect = true,
  $horizon_cert = undef,
  $horizon_key  = undef,
  $horizon_ca   = undef,
) {

  include ::horizon::params
  include ::apache
  include ::apache::mod::wsgi

  file { $::horizon::params::httpd_config_file: }

  Package['horizon'] -> Package[$::horizon::params::http_service]
  File[$::horizon::params::config_file] ~> Service[$::horizon::params::http_service]

  file { $::horizon::params::logdir:
    ensure  => directory,
    owner   => $::horizon::params::apache_user,
    group   => $::horizon::params::apache_group,
    before  => Service[$::horizon::params::http_service],
    mode    => '0751',
    require => Package['horizon']
  }

  if $ssl_redirect and $listen_ssl {
    $redirect_match = '(.*)'
    $redirect_url   = "https://${servername}"
  } else {
    $redirect_match = '^/$'
    $redirect_url   = $::horizon::params::root_url
  }

  apache::vhost { 'horizon_vhost':
    ip                   => $bind_address,
    servername           => $servername,
    serveraliases        => any2array($fqdn),
    port                 => 80,
    docroot              => '/var/www/',
    access_log_file      => 'horizon_access.log',
    error_log_file       => 'horizon_error.log',
    priority             => '15',
    wsgi_script_aliases  => hash([$::horizon::params::root_url, $::horizon::params::django_wsgi]),
    redirectmatch_status => 'permanent',
    redirectmatch_regexp => "${redirect_match} ${redirect_url}"
  }

  if $listen_ssl {
    include ::apache::mod::ssl

    if $horizon_ca == undef {
      fail('The horizon_ca parameter is required when listen_ssl is true')
    }

    if $horizon_cert == undef {
      fail('The horizon_cert parameter is required when listen_ssl is true')
    }

    if $horizon_key == undef {
      fail('The horizon_key parameter is required when listen_ssl is true')
    }

    apache::vhost { 'horizon_ssl_vhost':
      ip                   => $bind_address,
      servername           => $servername,
      serveraliases        => any2array($fqdn),
      port                 => 443,
      docroot              => '/var/www/',
      access_log_file      => 'horizon_ssl_access.log',
      error_log_file       => 'horizon_ssl_error.log',
      priority             => '15',
      ssl                  => true,
      ssl_cert             => $horizon_cert,
      ssl_key              => $horizon_key,
      ssl_ca               => $horizon_ca,
      wsgi_script_aliases  => hash([$::horizon::params::root_url, $::horizon::params::django_wsgi]),
      redirectmatch_status => 'permanent',
      redirectmatch_regexp => "^/$ ${::horizon::params::root_url}"
    }
  }
}
