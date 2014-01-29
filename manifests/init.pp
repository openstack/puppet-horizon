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
#    (optional) Package ensure state. Defaults to 'present'.
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
#  [*keystone_url*]
#    (optional) Full url of keystone public endpoint. (Defaults to 'http://127.0.0.1:5000/v2.0')
#    Use this parameter in favor of keystone_host, keystone_port and keystone_scheme.
#
#  [*keystone_scheme*]
#    (optional) DEPRECATED: Use keystone_url instead.
#    Scheme of the Keystone service. (Defaults to 'http')
#    Setting this parameter overrides keystone_url parameter.
#
#  [*keystone_host*]
#    (optional) DEPRECATED: Use keystone_url instead.
#    IP address of the Keystone service. (Defaults to '127.0.0.1')
#    Setting this parameter overrides keystone_url parameter.
#
#  [*keystone_port*]
#    (optional) DEPRECATED: Use keystone_url instead.
#    Port of the Keystone service. (Defaults to 5000)
#    Setting this parameter overrides keystone_url parameter.
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
#  [*local_settings_template*]
#    (optional) Location of template to use for local_settings.py generation.
#    Defaults to 'horizon/local_settings.py.erb'.
#
#  [*help_url*]
#    (optional) Location where the documentation should point.
#    Defaults to 'http://docs.openstack.org'.
#
#  [*compress_offline*]
#    (optional) Boolean to enable offline compress of assets.
#    Defaults to True
#
#  [*configure_apache*]
#    (optional) Configure Apache for Horizon. (Defaults to true)
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
# === Deprecation notes
#
# If any value is provided for keystone_scheme, keystone_host or keystone_port parameters,
# keystone_url will be completely ignored.
#
# === Examples
#
#  class { 'horizon':
#    secret       => 's3cr3t',
#    keystone_url => 'https://10.0.0.10:5000/v2.0',
#  }
#
class horizon(
  $secret_key,
  $fqdn                    = $::fqdn,
  $package_ensure          = 'present',
  $cache_server_ip         = '127.0.0.1',
  $cache_server_port       = '11211',
  $swift                   = false,
  $horizon_app_links       = false,
  $keystone_url            = 'http://127.0.0.1:5000/v2.0',
  $keystone_default_role   = '_member_',
  $django_debug            = 'False',
  $openstack_endpoint_type = undef,
  $secondary_endpoint_type = undef,
  $api_result_limit        = 1000,
  $log_level               = 'DEBUG',
  $can_set_mount_point     = 'True',
  $help_url                = 'http://docs.openstack.org',
  $local_settings_template = 'horizon/local_settings.py.erb',
  $configure_apache        = true,
  $bind_address            = '0.0.0.0',
  $listen_ssl              = false,
  $horizon_cert            = undef,
  $horizon_key             = undef,
  $horizon_ca              = undef,
  $compress_offline        = 'True',
  # DEPRECATED PARAMETERS
  $keystone_host           = undef,
  $keystone_port           = undef,
  $keystone_scheme         = undef,
) {

  include ::horizon::params

  if $swift {
    warning('swift parameter is deprecated and has no effect.')
  }

  if $keystone_scheme {
    warning('The keystone_scheme parameter is deprecated, use keystone_url instead.')
  }

  if $keystone_host {
    warning('The keystone_host parameter is deprecated, use keystone_url instead.')
  }

  if $keystone_port {
    warning('The keystone_port parameter is deprecated, use keystone_url instead.')
  }

  Service <| title == 'memcached' |> -> Class['horizon']

  package { 'horizon':
    ensure  => $package_ensure,
    name    => $::horizon::params::package_name,
  }

  file { $::horizon::params::config_file:
    content => template($local_settings_template),
    mode    => '0644',
    require => Package['horizon'],
  }

  if $configure_apache {
    class { 'horizon::wsgi::apache':
      bind_address => $bind_address,
      listen_ssl   => $listen_ssl,
      horizon_cert => $horizon_cert,
      horizon_key  => $horizon_key,
      horizon_ca   => $horizon_ca,
    }
  }
}
