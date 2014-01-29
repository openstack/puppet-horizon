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
  $bind_address = '0.0.0.0',
  $listen_ssl   = false,
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

  file_line { 'horizon_redirect_rule':
    path    => $::horizon::params::httpd_config_file,
    line    => "RedirectMatch permanent ^/$ ${::horizon::params::root_url}/",
    require => Package['horizon'],
    notify  => Service[$::horizon::params::http_service]
  }

  file_line { 'httpd_listen_on_bind_address_80':
    path    => $::horizon::params::httpd_listen_config_file,
    match   => '^Listen (.*):?80$',
    line    => "Listen ${bind_address}:80",
    require => Package['horizon'],
    notify  => Service[$::horizon::params::http_service],
  }

  if $listen_ssl {
    include apache::mod::ssl

    if $horizon_ca == undef {
      fail('The horizon_ca parameter is required when listen_ssl is true')
    }

    if $horizon_cert == undef {
      fail('The horizon_cert parameter is required when listen_ssl is true')
    }

    if $horizon_key == undef {
      fail('The horizon_key parameter is required when listen_ssl is true')
    }

    file_line { 'httpd_listen_on_bind_address_443':
      path    => $::horizon::params::httpd_listen_config_file,
      match   => '^Listen (.*):?443$',
      line    => "Listen ${bind_address}:443",
      require => Package['horizon'],
      notify  => Service[$::horizon::params::http_service],
    }

    # Enable SSL Engine
    file_line{'httpd_sslengine_on':
      path    => $::horizon::params::httpd_listen_config_file,
      match   => '^SSLEngine ',
      line    => 'SSLEngine on',
      notify  => Service[$::horizon::params::http_service],
      require => Class['apache::mod::ssl'],
    }

    # set the name of the ssl cert and key file
    file_line{'httpd_sslcert_path':
      path    => $::horizon::params::httpd_listen_config_file,
      match   => '^SSLCertificateFile ',
      line    => "SSLCertificateFile ${horizon_cert}",
      notify  => Service[$::horizon::params::http_service],
      require => Class['apache::mod::ssl'],
    }

    file_line{'httpd_sslkey_path':
      path    => $::horizon::params::httpd_listen_config_file,
      match   => '^SSLCertificateKeyFile ',
      line    => "SSLCertificateKeyFile ${horizon_key}",
      notify  => Service[$::horizon::params::http_service],
      require => Class['apache::mod::ssl'],
    }

    file_line{'httpd_sslca_path':
      path    => $::horizon::params::httpd_listen_config_file,
      match   => '^SSLCACertificateFile ',
      line    => "SSLCACertificateFile ${horizon_ca}",
      notify  => Service[$::horizon::params::http_service],
      require => Class['apache::mod::ssl'],
    }
  }

  $django_wsgi = '/usr/share/openstack-dashboard/openstack_dashboard/wsgi/django.wsgi'

  file_line { 'horizon root':
    path    => $::horizon::params::httpd_config_file,
    line    => "WSGIScriptAlias ${::horizon::params::root_url} ${django_wsgi}",
    match   => 'WSGIScriptAlias ',
    require => Package['horizon'],
  }
}
