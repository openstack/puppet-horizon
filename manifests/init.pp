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
#  [*quantum*]
#    (optional) Enable Quantum interface extension. Defaults to false.
#
#  [*horizon_app_links*]
#    (optional) Array of arrays that can be used to add call-out links
#    to the dashboard for other apps. There is no specific requirement
#    for these apps to be for monitoring, that's just the defacto purpose.
#    Each app is defined in two parts, the display name, and
#    the URIDefaults to false. Defaults to false. (no app links)
#
#  [*keystone_host*]
#    (optional) IP address of the Keystone service. Defaults to '127.0.0.1'.
#
#  [*keystone_port*]
#    (optional) Port of the Keystone service. Defaults to 5000.
#
#  [*keystone_scheme*]
#    (optional) Scheme of the Keystone service. Defaults to 'http'.
#
#  [*keystone_default_role*]
#    (optional) Default Keystone role for new users. Defaults to 'Member'.
#
#  [*django_debug*]
#    (optional) Enable or disable Django debugging. Defaults to 'False'.
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
class horizon(
  $secret_key,
  $package_ensure          = 'present',
  $bind_address            = '0.0.0.0',
  $cache_server_ip         = '127.0.0.1',
  $cache_server_port       = '11211',
  $swift                   = false,
  $quantum                 = false,
  $horizon_app_links       = false,
  $keystone_host           = '127.0.0.1',
  $keystone_port           = 5000,
  $keystone_scheme         = 'http',
  $keystone_default_role   = 'Member',
  $django_debug            = 'False',
  $api_result_limit        = 1000,
  $log_level               = 'DEBUG',
  $can_set_mount_point     = 'True',
  $listen_ssl              = false,
  $django_wsgi            = '/usr/share/openstack-dashboard/openstack_dashboard/wsgi/django.wsgi'
) {

  include horizon::params
  include apache::mod::wsgi
  include apache

  # I am totally confused by this, I do not think it should be installed...
  if ($::osfamily == 'Debian') {
    package { 'node-less': }
  }

  file { $::horizon::params::httpd_config_file: }

  Service <| title == 'memcached' |> -> Class['horizon']

  package { 'horizon':
    name    => $::horizon::params::package_name,
    ensure  => $package_ensure,
    require => Package[$::horizon::params::http_service],
  }

  file { $::horizon::params::config_file:
    content => template('horizon/local_settings.py.erb'),
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

  if $::osfamily == 'RedHat' {
    file_line { 'horizon_redirect_rule':
      path    => $::horizon::params::httpd_config_file,
      line    => 'RedirectMatch permanent ^/$ /dashboard/',
      require => Package['horizon'],
      notify  => Service[$::horizon::params::http_service]
    }
  }

  file_line { 'httpd_listen_on_bind_address_80':
    path    => $::horizon::params::httpd_listen_config_file,
    match   => '^Listen (.*):?80$',
    line    => "Listen ${bind_address}:80",
    require => Package['horizon'],
    notify  => Service[$::horizon::params::http_service],
  }

  if $listen_ssl {
    file_line { 'httpd_listen_on_bind_address_443':
      path    => $::horizon::params::httpd_listen_config_file,
      match   => '^Listen (.*):?443$',
      line    => "Listen ${bind_address}:443",
      require => Package['horizon'],
      notify  => Service[$::horizon::params::http_service],
    }
  }

  file_line { 'horizon root':
    path    => $::horizon::params::httpd_config_file,
    line    => "WSGIScriptAlias ${::horizon::params::root_url} ${django_wsgi}",
    match   => 'WSGIScriptAlias ',
    require => Package['horizon'],
    notify  => Service[$::horizon::params::http_service],
  }
}
