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
#  [*cache_server_url*]
#    (optional) URL of a cache server.
#    This allows arbitary strings to be set as CACHE BACKEND LOCATION.
#    Defaults to undef.
#
#  [*cache_server_ip*]
#    (optional) Memcached IP address. Can be a string, or an array.
#    Defaults to undef.
#
#  [*cache_server_port*]
#    (optional) Memcached port. Defaults to '11211'.
#
#  [*manage_memcache_package*]
#    (optional) Boolean if we should manage the memcache package.
#    Defaults to true
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
#    (optional) Default Keystone role for new users. Defaults to 'member'.
#
#  [*django_debug*]
#    (optional) Enable or disable Django debugging. Defaults to 'False'.
#
#  [*site_branding*]
#    (optional) Set the SITE_BRANDING config option that controls the
#    title of the web pages in the browser. Defaults to 'undef'.
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
#  [*dropdown_max_items*]
#    (optional) Specify a maximum number of items to display in a dropdown.
#    Defaults to 30
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
#  [*instance_options*]
#    (optional) A hash of parameters to enable or disable instance options
#    when using the launch instance options under Compute Instances tab.
#    These options include:
#      'config_drive': Boolean to set default value of config drive options.
#        A value of 'True' to have a check in the checkbox or 'False' to have it
#        unchecked.
#        Defaults to True.
#      'create_volume': Boolean to set 'Create Volume' to 'Yes' or 'No' on source
#        options. Values are True (Yes) or False (No).
#        Defaults to True.
#      'disable_image': Boolean to not show 'Image' as a boot source option.
#        Defaults to False.
#      'disable_instance_snapshot': Boolean to not show 'Instance Snapshot' as a
#        boot source option.
#        Defaults to False.
#      'disable_volume': Boolean to not show 'Volume' as a boot source option.
#        Defaults to False.
#      'disable_volume_snapshot': Boolean to not show 'Volume Snapshot' as a
#        boot source option.
#        Defaults to False.
#      'enable_scheduler_hints': Boolean to allow scheduler hints to be provided.
#        Defaults to True.
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
#  [*http_port*]
#    (optional) Port to use for the HTTP virtual host. (Defaults to 80)
#
#  [*https_port*]
#    (optional) Port to use for the HTTPS virtual host. (Defaults to 443)
#
#  [*ssl_no_verify*]
#    (optionsl) Disable SSL hostname verifying. Set it if you don't have
#    properly configured DNS which will resolve hostnames for SSL endpoints
#    Horizon will connect to. (Defaults to false)
#
#  [*openstack_ssl_cacert*]
#    (optional) The CA certificate to use to verify SSL
#    openstack connection.
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
# [*ssl_verify_client*]
#   Set the Certificate verification level for Client Authentication.
#   Defaults to undef
#
#  [*wsgi_processes*]
#    (optional) Number of Horizon processes to spawn
#    Defaults to $::os_workers
#
#  [*wsgi_threads*]
#    (optional) Number of thread to run in a Horizon process
#    Defaults to '1'
#
#  [*vhost_extra_params*]
#    (optional) extra parameter to pass to the apache::vhost class
#    Defaults to undef
#
#  [*file_upload_temp_dir*]
#    (optional) Location to use for temporary storage of images uploaded
#    You must ensure that the path leading to the directory is created
#    already, only the last level directory is created by this manifest.
#    Specify an absolute pathname.
#    Defaults to /tmp
#
#  [*policy_files_path*]
#    (Optional) The path to the policy files
#    Defaults to undef.
#
#  [*policy_files*]
#    (Optional) Policy files
#    Defaults to undef.
#
#  [*secure_cookies*]
#    (optional) Enables security settings for cookies. Useful when using
#    https on public sites. See: https://docs.openstack.org/security-guide/dashboard/cookies.html
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
#  [*keystone_domain_choices*]
#    (optional) A hash of hashes to populate a dropdown for the domain field on
#    the horizon login page.
#      Example: [
#         {'name' => 'default', 'display' => 'The default domain'},
#         {'name' => 'LDAP', 'display' => 'The LDAP Catalog'},
#      ]
#    Defaults to undef
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
#  [*root_path*]
#    (optional) The path to the location of static assets.
#    Defaults to "${::horizon::params::static_path}/openstack-dashboard"
#
#  [*access_log_format*]
#    (optional) The log format for the access log.
#    Defaults to false
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
#   (optional) The default theme to use from list of available themes. Value should be theme_name.
#   Defaults to false
#
#  [*password_autocomplete*]
#    (optional) Whether to instruct the client browser to autofill the login form password
#    Valid values are 'on' and 'off'
#    Defaults to 'off'
#
#  [*images_panel*]
#    (optional) Enabled panel for images.
#    Valid values are 'legacy' and 'angular'
#    Defaults to 'legacy'
#
#  [*create_image_defaults*]
#    (optional) A dictionary of default settings for create image modal.
#    Defaults to undef - will not add entry to local settings.
#
#  [*password_retrieve*]
#    (optional) Enables the use of 'Retrieve Password' in the Horizon Web UI.
#    Defaults to false
#
#  [*disable_password_reveal*]
#    (optional) Disables the use of reveal button for passwords in the UI.
#    Defaults to false
#
#  [*enforce_password_check*]
#    (optional) Disables Admin password prompt on Change Password form.
#    Defaults to false
#
#  [*enable_secure_proxy_ssl_header*]
#    (optional) Enables the SECURE_PROXY_SSL_HEADER option which makes django
#    take the X-Forwarded-Proto header into account. Note that this is only
#    recommended if you're running horizon behind a proxy.
#    Defaults to false
#
#  [*secure_proxy_addr_header*]
#    (optional) Enables the SECURE_PROXY_ADDR_HEADER option.
#    This setting specifies the name of the header with remote IP address.
#    The commom value for this setting
#    is HTTP_X_REAL_IP or HTTP_X_FORWARDED_FOR. Note that this is only
#    recommended if you're running horizon behind a proxy.
#    If not present, then REMOTE_ADDR header is used
#    Defaults to undef
#
#  [*disallow_iframe_embed*]
#    (optional)DISALLOW_IFRAME_EMBED can be used to prevent Horizon from being embedded
#    within an iframe. Legacy browsers are still vulnerable to a Cross-Frame
#    Scripting (XFS) vulnerability, so this option allows extra security hardening
#    where iframes are not used in deployment. Default setting is True.
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
#  [*password_validator*]
#    (optional) Horizon provides a password validation check, which OpenStack cloud
#    operators can use to enforce password complexity checks for users within horizon.
#    A dictionary containing a regular expression can be used for password validation
#    with help text that is displayed if the password does not pass validation.
#
#  [*password_validator_help*]
#    (optional) Help text to display when password validation fails in horizon.
#
#  [*enable_user_pass*]
#    (optional) Enable the password field while launching a Heat stack.
#    Set this parameter to undef or 'UNSET' if horizon::dashboards::heat is
#    used.
#    Defaults to true
#
#  [*customization_module*]
#    (optional) Horizon has a global override mechanism available to perform
#    customizations. This adds a key - customization_module - to HORIZON_CONFIG
#    dictionary in local_settings.py. The value should be a string with the
#    path to your module containing modifications in dotted python path
#    notation.
#    Defaults to undef
#
#    Example:
#      customization_module => "my_project.overrides"
#
#  [*horizon_upload_mode*]
#    (optional)  Horizon provides the upload mode. The default mode is legacy, off
#     will disable the function in Horizon, direct will allow the user agent to directly
#     talk to the glance-api.
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
  $cache_server_url                    = undef,
  $cache_server_ip                     = undef,
  $cache_server_port                   = '11211',
  $manage_memcache_package             = true,
  $horizon_app_links                   = false,
  $keystone_url                        = 'http://127.0.0.1:5000',
  $keystone_default_role               = 'member',
  $django_debug                        = 'False',
  $site_branding                       = undef,
  $openstack_endpoint_type             = undef,
  $secondary_endpoint_type             = undef,
  $available_regions                   = undef,
  $api_result_limit                    = 1000,
  $dropdown_max_items                  = 30,
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
  $http_port                           = 80,
  $https_port                          = 443,
  $ssl_no_verify                       = false,
  $openstack_ssl_cacert                = '',
  $ssl_redirect                        = true,
  $horizon_cert                        = undef,
  $horizon_key                         = undef,
  $horizon_ca                          = undef,
  $ssl_verify_client                   = undef,
  $wsgi_processes                      = $::os_workers,
  $wsgi_threads                        = '1',
  $compress_offline                    = true,
  $hypervisor_options                  = {},
  $cinder_options                      = {},
  $keystone_options                    = {},
  $neutron_options                     = {},
  $instance_options                    = {},
  $file_upload_temp_dir                = '/tmp',
  $policy_files_path                   = undef,
  $policy_files                        = undef,
  $redirect_type                       = 'permanent',
  $api_versions                        = {'identity' => '3'},
  $keystone_multidomain_support        = false,
  $keystone_default_domain             = undef,
  $keystone_domain_choices             = undef,
  $image_backend                       = {},
  $overview_days_range                 = undef,
  $root_url                            = $::horizon::params::root_url,
  $root_path                           = "${::horizon::params::static_path}/openstack-dashboard",
  $access_log_format                   = false,
  $session_timeout                     = 1800,
  $timezone                            = 'UTC',
  $secure_cookies                      = false,
  $django_session_engine               = undef,
  $vhost_extra_params                  = undef,
  $available_themes                    = false,
  $default_theme                       = false,
  $password_autocomplete               = 'off',
  $images_panel                        = 'legacy',
  $create_image_defaults               = undef,
  $password_retrieve                   = false,
  $disable_password_reveal             = false,
  $enforce_password_check              = false,
  $enable_secure_proxy_ssl_header      = false,
  $secure_proxy_addr_header            = undef,
  $disallow_iframe_embed               = true,
  $websso_enabled                      = false,
  $websso_initial_choice               = undef,
  $websso_choices                      = undef,
  $websso_idp_mapping                  = undef,
  $password_validator                  = undef,
  $password_validator_help             = undef,
  $enable_user_pass                    = true,
  $customization_module                = undef,
  $horizon_upload_mode                 = undef,
) inherits ::horizon::params {

  include ::horizon::deps

  if $cache_server_url and $cache_server_ip {
    fail('Only one of cache_server_url or cache_server_ip can be set.')
  }

  if $cache_server_ip {
    $cache_server_ip_real = inet6_prefix($cache_server_ip)
  }

  $hypervisor_defaults = {
    'can_set_mount_point' => true,
    'can_set_password'    => false,
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

  # Default options for the LAUNCH_INSTANCE_DEFAULTS section.  These will
  # be merged with user-provided options when the local_settings.py.erb
  # template is interpolated.
  $instance_defaults = {
    'config_drive'              => false,
    'create_volume'             => true,
    'hide_create_volume'        => false,
    'disable_image'             => false,
    'disable_instance_snapshot' => false,
    'disable_volume'            => false,
    'disable_volume_snapshot'   => false,
    'enable_scheduler_hints'    => true,
  }

  Service <| title == 'memcached' |> -> Class['horizon']

  $hypervisor_options_real = merge($hypervisor_defaults,$hypervisor_options)
  $cinder_options_real     = merge($cinder_defaults,$cinder_options)
  $keystone_options_real   = merge($keystone_defaults, $keystone_options)
  $neutron_options_real    = merge($neutron_defaults,$neutron_options)
  $instance_options_real   = merge($instance_defaults,$instance_options)

  validate_legacy(Hash, 'validate_hash', $api_versions)
  validate_legacy(Enum['on', 'off'], 'validate_re', $password_autocomplete, [['^on$', '^off$']])
  validate_legacy(Enum['legacy', 'angular'], 'validate_re', $images_panel, [['^legacy$', '^angular$']])
  validate_legacy(Stdlib::Absolutepath, 'validate_absolute_path', $root_path)

  if $manage_memcache_package and $cache_backend =~ /MemcachedCache/ {
    ensure_packages('python-memcache', {
      name => $::horizon::params::memcache_package,
      tag  => ['openstack'],
    })
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
    require => Anchor['horizon::config::begin'],
    tag     => ['django-config'],
  }

  concat::fragment { 'local_settings.py':
    target  => $::horizon::params::config_file,
    content => template($local_settings_template),
    order   => '50',
  }

  file { $::horizon::params::conf_d_dir:
    ensure  => 'directory',
    mode    => '0755',
    owner   => $::horizon::params::wsgi_user,
    group   => $::horizon::params::wsgi_group,
    require => Anchor['horizon::config::begin'],
  }

  exec { 'refresh_horizon_django_cache':
    command     => "${::horizon::params::manage_py} collectstatic --noinput --clear",
    refreshonly => true,
    tag         => ['horizon-compress'],
  }

  exec { 'refresh_horizon_django_compress':
    command     => "${::horizon::params::manage_py} compress --force",
    refreshonly => true,
    tag         => ['horizon-compress'],
  }

  if $compress_offline {
    Concat<| tag == 'django-config' |> ~> Exec['refresh_horizon_django_compress']
    if $::os_package_type == 'rpm' {
      Concat<| tag == 'django-config' |> ~> Exec['refresh_horizon_django_cache'] -> Exec['refresh_horizon_django_compress']
    }
  }

  if $configure_apache {
    class { '::horizon::wsgi::apache':
      bind_address      => $bind_address,
      servername        => $servername,
      server_aliases    => $server_aliases,
      listen_ssl        => $listen_ssl,
      http_port         => $http_port,
      https_port        => $https_port,
      ssl_redirect      => $ssl_redirect,
      horizon_cert      => $horizon_cert,
      horizon_key       => $horizon_key,
      horizon_ca        => $horizon_ca,
      ssl_verify_client => $ssl_verify_client,
      wsgi_processes    => $wsgi_processes,
      wsgi_threads      => $wsgi_threads,
      extra_params      => $vhost_extra_params,
      redirect_type     => $redirect_type,
      root_url          => $root_url,
      root_path         => $root_path,
      access_log_format => $access_log_format,
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
