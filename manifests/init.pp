# == Class: horizon
#
# Installs Horizon dashboard with Apache
#
# === Parameters
#
#  [*secret_key*]
#    (required) Secret key. This is used by Django to provide cryptographic
#    signing, and should be set to a unique, unpredictable value.
#
#  [*fqdn*]
#    (optional) FQDN(s) used to access Horizon. This is used by Django for
#    security reasons. Can be set to * in environments where security is
#    deemed unimportant. Defaults to ::fqdn
#
#  [*package_ensure*]
#     (optional) Package ensure state. Defaults to 'present'.
#
#  [*cache_server_ip*]
#    (optional) Memcached IP address. Defaults to '127.0.0.1'.
#
#  [*cache_server_port*]
#    (optional) Memcached port. Defaults to '11211'.
#
#  [*swift*]
#    (optional) Enable Swift interface extension. Defaults to false.
#
#  [*horizon_app_links*]
#    (optional) Array of arrays that can be used to add call-out links
#    to the dashboard for other apps. There is no specific requirement
#    for these apps to be for monitoring, that's just the defacto purpose.
#    Each app is defined in two parts, the display name, and
#    the URIDefaults to false. Defaults to false. (no app links)
#
#  [*keystone_host*]
#    (optional) IP address of the Keystone service. Deprecated in favor of keystone_url.
#
#  [*keystone_port*]
#    (optional) Port of the Keystone service. Deprecated in favor of keystone_url.
#
#  [*keystone_scheme*]
#    (optional) Scheme of the Keystone service. Deprecated in favor of keystone_url.
#
#  [*keystone_url*]
#    (optional) Full url of keystone public endpoint.
#    Defaults to 'http://127.0.0.1:5000/v2.0'.
#    Use this parameter in favor of keystone_host, keystone_port and keystone_scheme.
#    Set to false to use the deprecated interface.
#
#  [*keystone_default_role*]
#    (optional) Default Keystone role for new users. Defaults to '_member_'.
#
#  [*django_debug*]
#    (optional) Enable or disable Django debugging. Defaults to 'False'.
#
#  [*openstack_endpoint_type*]
#    (optional) endpoint type to use for the endpoints in the Keystone
#    service catalog. Defaults to 'undef'.
#
#  [*secondary_endpoint_type*]
#    (optional) secondary endpoint type to use for the endpoints in the
#    Keystone service catalog. Defaults to 'undef'.
#
#  [*api_result_limit*]
#    (optional) Maximum number of Swift containers/objects to display
#    on a single page. Defaults to 1000.
#
#  [*log_level*]
#    (optional) Log level. Defaults to 'DEBUG'.
#
#  [*can_set_mount_point*]
#    (optional) Add the option to set the mount point from the UI.
#    Defaults to 'True'.
#
#  [*listen_ssl*]
#    (optional) Defaults to false.
#
#  [*local_settings_template*]
#    (optional) Location of template to use for local_settings.py generation.
#    Defaults to 'horizon/local_settings.py.erb'.
#
#  [*help_url*]
#    (optional) Location where the documentation should point.
#    Defaults to 'http://docs.openstack.org'.

class horizon(
  $secret_key,
  $fqdn                    = $::fqdn,
  $package_ensure          = 'present',
  $bind_address            = '0.0.0.0',
  $cache_server_ip         = '127.0.0.1',
  $cache_server_port       = '11211',
  $swift                   = false,
  $horizon_app_links       = false,
  $keystone_host           = undef,
  $keystone_port           = undef,
  $keystone_scheme         = undef,
  $keystone_url            = 'http://127.0.0.1:5000/v2.0',
  $keystone_default_role   = '_member_',
  $django_debug            = 'False',
  $openstack_endpoint_type = undef,
  $secondary_endpoint_type = undef,
  $api_result_limit        = 1000,
  $log_level               = 'DEBUG',
  $can_set_mount_point     = 'True',
  $listen_ssl              = false,
  $horizon_cert            = undef,
  $horizon_key             = undef,
  $horizon_ca              = undef,
  $help_url                = 'http://docs.openstack.org',
  $local_settings_template = 'horizon/local_settings.py.erb'
) {

  include horizon::params
  include apache
  include apache::mod::wsgi

  if $swift {
    warning('swift parameter is deprecated and has no effect.')
  }

  if $keystone_host or $keystone_port or $keystone_scheme {
    warning('keystone_host, keystone_port and keystone_scheme are deprecated. Use keystone_url instead.')
    if $keystone_url {
      warning('keystone_host, keystone_port and keystone_scheme are ignored when keystone_url is set.')
    }
  }

  file { $::horizon::params::httpd_config_file: }

  Service <| title == 'memcached' |> -> Class['horizon']

  package { 'horizon':
    ensure  => $package_ensure,
    name    => $::horizon::params::package_name,
    require => Package[$::horizon::params::http_service],
  }

  file { $::horizon::params::config_file:
    content => template($local_settings_template),
    mode    => '0644',
    notify  => Service[$::horizon::params::http_service],
    require => Package['horizon'],
  }

  file { $::horizon::params::logdir:
    ensure  => directory,
    mode    => '0751',
    owner   => $::horizon::params::apache_user,
    group   => $::horizon::params::apache_group,
    before  => Service[$::horizon::params::http_service],
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

    if $horizon_ca == undef or $horizon_cert == undef or $horizon_key == undef {
      fail('The horizon CA, cert and key are all required.')
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
