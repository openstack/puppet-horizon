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
#  [*servername*]
#    (optional) FQDN used for the Server Name directives
#    Defaults to ::fqdn.
#
#  [*allowed_hosts*]
#    (optional) List of hosts which will be set as value of ALLOWED_HOSTS
#    parameter in settings_local.py. This is used by Django for
#    security reasons. Can be set to * in environments where security is
#    deemed unimportant.
#    Defaults to ::fqdn.
#
#  [*server_aliases*]
#    (optional) List of names which should be defined as ServerAlias directives
#    in vhost.conf.
#    Defaults to ::fqdn.
#
#  [*package_ensure*]
#    (optional) Package ensure state. Defaults to 'present'.
#
#  [*cache_backend*]
#   (optional) Horizon cache backend.
#   Defaults: 'django.core.cache.backends.locmem.LocMemCache'
#
#  [*cache_options*]
#   (optional) A hash of parameters to enable specific cache options.
#   Defaults to undef
#
#  [*cache_server_ip*]
#    (optional) Memcached IP address. Can be a string, or an array.
#    Defaults to undef.
#
#  [*cache_server_port*]
#    (optional) Memcached port. Defaults to '11211'.
#
#  [*horizon_app_links*]
#    (optional) Array of arrays that can be used to add call-out links
#    to the dashboard for other apps. There is no specific requirement
#    for these apps to be for monitoring, that's just the defacto purpose.
#    Each app is defined in two parts, the display name, and
#    the URIDefaults to false. Defaults to false. (no app links)
#
#  [*keystone_url*]
#    (optional) Full url of keystone public endpoint. (Defaults to 'http://127.0.0.1:5000')
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
#  [*available_regions*]
#    (optional) List of available regions. Value should be a list of tuple:
#    [ ['urlOne', 'RegionOne'], ['urlTwo', 'RegionTwo'] ]
#    Defaults to undef.
#
#  [*api_result_limit*]
#    (optional) Maximum number of Swift containers/objects to display
#    on a single page. Defaults to 1000.
#
#  [*log_handler*]
#    (optional) Log handler. Defaults to 'file'
#
#  [*log_level*]
#    (optional) Log level. Defaults to 'INFO'. WARNING: Setting this to
#    DEBUG will let plaintext passwords be logged in the Horizon log file.
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
#  [*hypervisor_options*]
#    (optional) A hash of parameters to enable features specific to
#    Hypervisors. These include:
#    'can_set_mount_point': Boolean to enable or disable mount point setting
#      Defaults to 'True'.
#    'can_set_password': Boolean to enable or disable VM password setting.
#      Works only with Xen Hypervisor.
#      Defaults to 'False'.
#
#  [*cinder_options*]
#    (optional) A hash of parameters to enable features specific to
#    Cinder.  These include:
#    'enable_backup': Boolean to enable or disable Cinders's backup feature.
#      Defaults to False.
#
#  [*keystone_options*]
#    (optional) A hash of parameters to enable features specific to
#    Keystone.  These include:
#    'name': String
#    'can_edit_user': Boolean
#    'can_edit_group': Boolean
#    'can_edit_project': Boolean
#    'can_edit_domain': Boolean
#    'can_edit_role': Boolean
#
#  [*neutron_options*]
#    (optional) A hash of parameters to enable features specific to
#    Neutron.  These include:
#    'enable_lb': Boolean to enable or disable Neutron's LBaaS feature.
#      Defaults to False.
#    'enable_firewall': Boolean to enable or disable Neutron's FWaaS feature.
#      Defaults to False.
#    'enable_quotas': Boolean to enable or disable Neutron quotas.
#      Defaults to True.
#    'enable_security_group': Boolean to enable or disable Neutron
#      security groups.  Defaults to True.
#    'enable_vpn': Boolean to enable or disable Neutron's VPNaaS feature.
#      Defaults to False.
#    'enable_distributed_router': Boolean to enable or disable Neutron
#      distributed virtual router (DVR) feature in the Router panel.
#      Defaults to False.
#    'enable_ha_router': Enable or disable HA (High Availability) mode in
#      Neutron virtual router in the Router panel.  Defaults to False.
#    'profile_support':  A string indiciating which plugin-specific
#      profiles to enable.  Defaults to 'None', other options include
#      'cisco'.
#
#  [*configure_apache*]
#    (optional) Configure Apache for Horizon. (Defaults to true)
#
#  [*bind_address*]
#    (optional) Bind address in Apache for Horizon. (Defaults to undef)
#
#  [*listen_ssl*]
#    (optional) Enable SSL support in Apache. (Defaults to false)
#
#  [*ssl_no_verify*]
#    (optionsl) Disable SSL hostname verifying. Set it if you don't have
#    properly configured DNS which will resolve hostnames for SSL endpoints
#    Horizon will connect to. (Defaults to false)
#
#  [*ssl_redirect*]
#    (optional) Whether to redirect http to https
#    Defaults to True
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
#  [*vhost_extra_params*]
#    (optionnal) extra parameter to pass to the apache::vhost class
#    Defaults to undef
#
#  [*file_upload_temp_dir*]
#    (optional) Location to use for temporary storage of images uploaded
#    You must ensure that the path leading to the directory is created
#    already, only the last level directory is created by this manifest.
#    Specify an absolute pathname.
#    Defaults to /tmp
#
# [*policy_files_path*]
#   (Optional) The path to the policy files
#   Defaults to undef.
#
# [*policy_files*]
#   (Optional) Policy files
#   Defaults to undef.
#
#  [*secure_cookies*]
#    (optional) Enables security settings for cookies. Useful when using
#    https on public sites. See: http://docs.openstack.org/developer/horizon/topics/deployment.html#secure-site-recommendations
#    Defaults to false
#
#  [*django_session_engine*]
#    (optional) Selects the session engine for Django to use.
#    Defaults to undef - will not add entry to local settings.
#
#  [*redirect_type*]
#    (optional) What type of redirect to use when redirecting an http request
#    for a user. This should be either 'temp' or 'permanent'. Setting this value
#    to 'permanent' will result in the use of a 301 redirect which may be cached
#    by a user's browser.  Setting this value to 'temp' will result in the use
#    of a 302 redirect which is not cached by browsers and may solve issues if
#    users report errors accessing horizon. Only used if configure_apache is
#    set to true.
#    Defaults to 'permanent'
#
#  [*api_versions*]
#    (optional) A hash of parameters to set specific api versions.
#    Example: api_versions => {'identity' => 3}
#    Default to 'identity' => 3
#
#  [*keystone_multidomain_support*]
#    (optional) Enables multi-domain in horizon. When this is enabled, it will require user to enter
#    the Domain name in addition to username for login.
#    Default to false
#
#  [*keystone_default_domain*]
#    (optional) Overrides the default domain used when running on single-domain model with Keystone V3.
#    All entities will be created in the default domain.
#    Default to undef
#
#  [*image_backend*]
#    (optional) Overrides the default image backend settings.  This allows the list of supported
#    image types etc. to be explicitly defined.
#    Example: image_backend => { 'image_formats' => { '' => 'Select type', 'qcow2' => 'QCOW2' } }
#    Default to empty hash
#
#  [*overview_days_range*]
#    (optional) The default date range in the Overview panel meters - either <today> minus N
#    days (if the value is integer N), or from the beginning of the current month
#    until today (if it's undefined). This setting should be used to limit the amount
#    of data fetched by default when rendering the Overview panel.
#    Defaults to undef.
#
#  [*root_url*]
#    (optional) The base URL used to contruct horizon web addresses.
#    Defaults to '/dashboard' or '/horizon' depending OS
#
#  [*session_timeout*]
#    (optional) The session timeout for horizon in seconds. After this many seconds of inactivity
#    the user is logged out.
#    Defaults to 1800.
#
#  [*timezone*]
#    (optional) The timezone of the server.
#    Defaults to 'UTC'.
#
#  [*available_themes*]
#    (optional) An array of hashes detailing available themes. Each hash must
#    have the followings keys for themes to be made available; name, label,
#    path. Defaults to false
#
#    { 'name' => 'theme_name', 'label' => 'theme_label', 'path' => 'theme_path' }
#
#    Example:
#    class { 'horizon':
#      available_themes => [
#        { 'name' => 'default', 'label' => 'Default', 'path' => 'themes/default'},
#        { 'name' => 'material', 'label' => 'Material', 'path' => 'themes/material'},
#      ]
#    }
#
#   Or in Hiera:
#   horizon::available_themes:
#     - { name: 'default', label: 'Default', path: 'themes/default' }
#     - { name: 'material', label: 'Material', path: 'themes/material' }
#
#  [*default_theme*]
#    (optional) The default theme to use from list of available themes. Value should be theme_name.
#    Defaults to false
#
# [*password_autocomplete*]
#   (optional) Whether to instruct the client browser to autofill the login form password
#   Valid values are 'on' and 'off'
#   Defaults to 'off'
#
# [*images_panel*]
#   (optional) Enabled panel for images.
#   Valid values are 'legacy' and 'angular'
#   Defaults to 'legacy'
#
#  [*websso_enabled*]
#    (optional)Enable the WEBSSO_ENABLED option which turn on the keystone web
#    single-sign-on if set to true.
#    Default to false
#
#  [*websso_initial_choice*]
#    (optional)Set the WEBSSO_INITIAL_CHOICE option used to determine which
#    authentication choice to show as default.
#    Defaults to undef
#
#  [*websso_choices*]
#    (optional)Set the WEBSSO_CHOICES option, A list of authentication
#    mechanisms which include keystone federation protocols and identity
#    provide protocol mapping keys (WEBSSO_IDP_MAPPING).
#    Default to undef
#
#    Example:
#      websso_choices => [
#        ['oidc', 'OpenID Connect'],
#        ['saml2', 'Security Assertion Markup Language']
#      ]
#
#  [*websso_idp_mapping*]
#    (optional)Set the WEBSSO_IDP_MAPPING option.
#    A dictionary of specific identity provider and protocol combinations.
#    From theselected authentication mechanism, the value will be looked up as
#    keys in the dictionary. If a match is found, it will redirect the user to
#    a identity provider and federation protocol specific WebSSO endpoint in
#    keystone, otherwise it will use the value as the protocol_id when
#    redirecting to the WebSSO by protocol endpoint.
#    Default to undef
#
#    Example:
#      websso_idp_mapping => {
#        'acme_oidc'  => ['acme', 'oidc'],
#        'acme_saml2' => ['acme', 'saml2'],
#      }
#
# === DEPRECATED group/name
#
#  [*fqdn*]
#    (optional) DEPRECATED, use allowed_hosts and server_aliases instead.
#    FQDN(s) used to access Horizon. This is used by Django for
#    security reasons. Can be set to * in environments where security is
#    deemed unimportant. Also used for Server Aliases in web configs.
#    Defaults to undef
#
#  [*custom_theme_path*]
#    (optional) The directory location for the theme (e.g., "static/themes/blue")
#    Default to undef
#
#  [*tuskar_ui*]
#    (optional) Boolean to enable Tuskar-UI related configuration (http://tuskar-ui.readthedocs#
#    Defaults to undef
#
#  [*tuskar_ui_ironic_discoverd_url*]
#    (optional) Tuskar-UI - Ironic Discoverd API endpoint
#    Defaults to undef
#
#  [*tuskar_ui_undercloud_admin_password*]
#    (optional) Tuskar-UI - Undercloud admin password used to authenticate admin user in Tuskar#
#    It is required by Heat to perform certain actions.
#    Defaults to undef
#
#  [*tuskar_ui_deployment_mode*]
#    (optional) Tuskar-UI - Deployment mode ('poc' or 'scale')
#    Defaults to undef
#
# === Examples
#
#  class { 'horizon':
#    secret_key       => 's3cr3t',
#    keystone_url => 'https://10.0.0.10:5000',
#    available_regions => [
#      ['http://region-1.example.com:5000', 'Region-1'],
#      ['http://region-2.example.com:5000', 'Region-2']
#    ]
#  }
#
class horizon(
  $secret_key,
  $package_ensure                      = 'present',
  $cache_backend                       = 'django.core.cache.backends.locmem.LocMemCache',
  $cache_options                       = undef,
  $cache_server_ip                     = undef,
  $cache_server_port                   = '11211',
  $horizon_app_links                   = false,
  $keystone_url                        = 'http://127.0.0.1:5000',
  $keystone_default_role               = '_member_',
  $django_debug                        = 'False',
  $openstack_endpoint_type             = undef,
  $secondary_endpoint_type             = undef,
  $available_regions                   = undef,
  $api_result_limit                    = 1000,
  $log_handler                         = 'file',
  $log_level                           = 'INFO',
  $help_url                            = 'http://docs.openstack.org',
  $local_settings_template             = 'horizon/local_settings.py.erb',
  $configure_apache                    = true,
  $bind_address                        = undef,
  $servername                          = $::fqdn,
  $server_aliases                      = $::fqdn,
  $allowed_hosts                       = $::fqdn,
  $listen_ssl                          = false,
  $ssl_no_verify                       = false,
  $ssl_redirect                        = true,
  $horizon_cert                        = undef,
  $horizon_key                         = undef,
  $horizon_ca                          = undef,
  $compress_offline                    = true,
  $hypervisor_options                  = {},
  $cinder_options                      = {},
  $keystone_options                    = {},
  $neutron_options                     = {},
  $file_upload_temp_dir                = '/tmp',
  $policy_files_path                   = undef,
  $policy_files                        = undef,
  $redirect_type                       = 'permanent',
  $api_versions                        = {'identity' => '3'},
  $keystone_multidomain_support        = false,
  $keystone_default_domain             = undef,
  $image_backend                       = {},
  $overview_days_range                 = undef,
  $root_url                            = $::horizon::params::root_url,
  $session_timeout                     = 1800,
  $timezone                            = 'UTC',
  $secure_cookies                      = false,
  $django_session_engine               = undef,
  $vhost_extra_params                  = undef,
  $available_themes                    = false,
  $default_theme                       = false,
  $password_autocomplete               = 'off',
  $images_panel                        = 'legacy',
  $websso_enabled                      = false,
  $websso_initial_choice               = undef,
  $websso_choices                      = undef,
  $websso_idp_mapping                  = undef,
  # DEPRECATED PARAMETERS
  $custom_theme_path                   = undef,
  $fqdn                                = undef,
  $tuskar_ui                           = undef,
  $tuskar_ui_ironic_discoverd_url      = undef,
  $tuskar_ui_undercloud_admin_password = undef,
  $tuskar_ui_deployment_mode           = undef,
) inherits ::horizon::params {

  $hypervisor_defaults = {
    'can_set_mount_point' => true,
    'can_set_password'    => false,
  }

  if $fqdn {

    warning("Parameter fqdn is deprecated. Please use parameter allowed_hosts for setting ALLOWED_HOSTS in \
settings_local.py and parameter server_aliases for setting ServerAlias directives in vhost.conf.")

    $final_allowed_hosts = $fqdn
    $final_server_aliases = $fqdn
  } else {
    $final_allowed_hosts = $allowed_hosts
    $final_server_aliases = $server_aliases
  }

  if $custom_theme_path {
    warning('custom_theme_path has been deprecated in mitaka and will be removed in a future release.')
  }

  if $tuskar_ui or $tuskar_ui_ironic_discoverd_url or $tuskar_ui_undercloud_admin_password or $tuskar_ui_deployment_mode {
    warning('tuskar module is no longer maintained, all tuskar parameters will be removed after Newton cycle.')
  }

  # Default options for the OPENSTACK_CINDER_FEATURES section. These will
  # be merged with user-provided options when the local_settings.py.erb
  # template is interpolated.
  $cinder_defaults = {
    'enable_backup'         => false,
  }

  # Default options for the OPENSTACK_KEYSTONE_BACKEND section. These will
  # be merged with user-provided options when the local_settings.py.erb
  # template is interpolated.
  $keystone_defaults = {
    'name'             => 'native',
    'can_edit_user'    => true,
    'can_edit_group'   => true,
    'can_edit_project' => true,
    'can_edit_domain'  => true,
    'can_edit_role'    => true,
  }

  # Default options for the OPENSTACK_NEUTRON_NETWORK section.  These will
  # be merged with user-provided options when the local_settings.py.erb
  # template is interpolated.
  $neutron_defaults = {
    'enable_lb'                 => false,
    'enable_firewall'           => false,
    'enable_quotas'             => true,
    'enable_security_group'     => true,
    'enable_vpn'                => false,
    'enable_distributed_router' => false,
    'enable_ha_router'          => false,
    'profile_support'           => 'None',
  }

  Service <| title == 'memcached' |> -> Class['horizon']

  $hypervisor_options_real = merge($hypervisor_defaults,$hypervisor_options)
  $cinder_options_real     = merge($cinder_defaults,$cinder_options)
  $keystone_options_real   = merge($keystone_defaults, $keystone_options)
  $neutron_options_real    = merge($neutron_defaults,$neutron_options)
  validate_hash($api_versions)
  validate_re($password_autocomplete, ['^on$', '^off$'])
  validate_re($images_panel, ['^legacy$', '^angular$'])

  if $cache_backend =~ /MemcachedCache/ {
    ensure_resources('package', { 'python-memcache' =>
      { name   => $::horizon::params::memcache_package,
        tag    => ['openstack']}})
  }

  package { 'horizon':
    ensure => $package_ensure,
    name   => $::horizon::params::package_name,
    tag    => ['openstack', 'horizon-package'],
  }

  concat { $::horizon::params::config_file:
    mode    => '0640',
    owner   => $::horizon::params::wsgi_user,
    group   => $::horizon::params::wsgi_group,
    require => Package['horizon'],
  }

  concat::fragment { 'local_settings.py':
    target  => $::horizon::params::config_file,
    content => template($local_settings_template),
    order   => '50',
  }

  exec { 'refresh_horizon_django_cache':
    command     => "${::horizon::params::manage_py} collectstatic --noinput --clear",
    refreshonly => true,
    require     => Package['horizon'],
  }

  exec { 'refresh_horizon_django_compress':
    command     => "${::horizon::params::manage_py} compress --force",
    refreshonly => true,
    require     => Package['horizon'],
  }

  if $compress_offline {
    Concat[$::horizon::params::config_file] ~> Exec['refresh_horizon_django_compress']
    if $::os_package_type == 'rpm' {
      Concat[$::horizon::params::config_file] ~> Exec['refresh_horizon_django_cache'] -> Exec['refresh_horizon_django_compress']
    }
  }

  if $configure_apache {
    class { '::horizon::wsgi::apache':
      bind_address   => $bind_address,
      servername     => $servername,
      server_aliases => $final_server_aliases,
      listen_ssl     => $listen_ssl,
      ssl_redirect   => $ssl_redirect,
      horizon_cert   => $horizon_cert,
      horizon_key    => $horizon_key,
      horizon_ca     => $horizon_ca,
      extra_params   => $vhost_extra_params,
      redirect_type  => $redirect_type,
      root_url       => $root_url
    }
  }

  if ! ($file_upload_temp_dir in ['/tmp','/var/tmp']) {
    file { $file_upload_temp_dir :
      ensure => directory,
      owner  => $::horizon::params::wsgi_user,
      group  => $::horizon::params::wsgi_group,
      mode   => '0755',
    }
  }

}
