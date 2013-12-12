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
#  [*listen_plain*]
#    (optional) Defaults to true, false disabled plain http access.
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
  $keystone_host           = '127.0.0.1',
  $keystone_port           = 5000,
  $keystone_scheme         = 'http',
  $keystone_default_role   = 'Member',
  $django_debug            = 'False',
  $api_result_limit        = 1000,
  $log_level               = 'DEBUG',
  $can_set_mount_point     = 'True',
  $listen_plain            = true,
  $listen_ssl              = false,
  $horizon_cert            = undef,
  $horizon_key             = undef,
  $horizon_ca              = undef,
  $help_url                = 'http://docs.openstack.org',
  $local_settings_template = 'horizon/local_settings.py.erb'
) {

  include horizon::params
  class {'apache': default_mods => false, default_vhost => false }
  include apache::mod::alias
  include apache::mod::mime
  include apache::mod::wsgi

  if $swift {
    warning('swift parameter is deprecated and has no effect.')
  }

  Service <| title == 'memcached' |> -> Class['horizon']

  package { 'horizon':
    ensure  => $package_ensure,
    name    => $::horizon::params::package_name,
    require => Package[$::horizon::params::http_service],
  }

  # common properties to both vhosts
  $django_wsgi = '/usr/share/openstack-dashboard/openstack_dashboard/wsgi/django.wsgi'
  $aliases = [ 
    { 
      alias => '/static', 
      path => '/usr/share/openstack-dashboard/openstack_dashboard/static/', 
    } 
  ]
  $wsgi_daemon_process_options = { 
    user => 'horizon', group => 'horizon', processes => '3', threads => '10',
  }

  # the horizon config file
  file { $::horizon::params::config_file:
    content => template($local_settings_template),
    mode    => '0644',
    notify  => Service[$::horizon::params::http_service],
    require => Package['horizon'],
  }

  # horizon logs go to their own dir
  file { $::horizon::params::logdir:
    ensure  => directory,
    mode    => '0751',
    owner   => $::horizon::params::apache_user,
    group   => $::horizon::params::apache_group,
    before  => Service[$::horizon::params::http_service],
    require => Package['horizon']
  }

  # FIXME: ensure old httpd config is gone (it keeps coming back on install?)
  file { '/etc/apache2/conf.d/openstack-dashboard.conf':
    ensure => absent,
  }

  File[$::horizon::params::config_file] -> File[$::horizon::params::logdir]
  -> File['/etc/apache2/conf.d/openstack-dashboard.conf'] -> Apache::Vhost[$bind_address]
  -> Apache::Vhost["${bind_address} ssl"]

  # non ssl vhost
  if $listen_plain {

    apache::vhost {$bind_address:
      servername                         => $bind_address,
      port                               => '80',
      docroot                            => '/var/www',
      aliases                            => $aliases,
      custom_fragment                    => "RedirectMatch permanent ^/$ ${::horizon::params::root_url}/",
      wsgi_daemon_process                => $::horizon::params::apache_user,
      wsgi_daemon_process_options        => $wsgi_daemon_process_options, 
      wsgi_process_group                 => $::horizon::params::apache_group,
      wsgi_script_aliases                => {
        "${::horizon::params::root_url}" => $django_wsgi,
      },
    }

  }

  # ssl vhost
  if $listen_ssl {

    include apache::mod::ssl

    if $horizon_ca == undef or $horizon_cert == undef or $horizon_key == undef {
      fail('The horizon CA, cert and key are all required.')
    }

    apache::vhost {"${bind_address} ssl":
      servername                         => $bind_address,
      port                               => '443',
      docroot                            => '/var/www',
      aliases                            => $aliases,
      custom_fragment                    => "RedirectMatch permanent ^/$ ${::horizon::params::root_url}/",
      ssl                                => true,
      ssl_cert                           => "${horizon_cert}",
      ssl_key                            => "${horizon_key}",
      ssl_ca                             => "${horizon_ca}",
      wsgi_daemon_process                => "${::horizon::params::apache_user}-ssl",
      wsgi_daemon_process_options        => $wsgi_daemon_process_options,
      wsgi_process_group                 => $::horizon::params::apache_group,
      wsgi_script_aliases                => {
        "${::horizon::params::root_url}" => $django_wsgi,
      },
    }

  }

}
