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
#    (optional) Package ensure state. Defaults to 'present'.
#
#  [*purge_conf_d_dir*]
#    (optional) Purge files in the local_settings.d directory
#    Defaults to false
#
#  [*servername*]
#    (optional) FQDN used for the Server Name directives
#    Defaults to facts['networking']['fqdn'].
#
#  [*allowed_hosts*]
#    (optional) List of hosts which will be set as value of ALLOWED_HOSTS
#    parameter in settings_local.py. This is used by Django for
#    security reasons. Can be set to * in environments where security is
#    deemed unimportant.
#    Defaults to facts['networking']['fqdn'].
#
#  [*server_aliases*]
#    (optional) List of names which should be defined as ServerAlias directives
#    in vhost.conf.
#    Defaults to facts['networking']['fqdn'].
#
#  [*memoized_max_size_default*]
#    (optional) Global default to help control memory usage when caching.
#    Defaults to undef
#
#  [*cache_backend*]
#   (optional) Horizon cache backend.
#   Defaults: 'django.core.cache.backends.locmem.LocMemCache'
#
#  [*cache_options*]
#   (optional) A hash of parameters to enable specific cache options.
#   Defaults to undef
#
#  [*cache_timeout*]
#   (optional) The default timeout, in seconds, to use for the cache.
#   Defaults to undef
#
#  [*cache_server_url*]
#    (optional) URL of a cache server.
#    This allows arbitrary strings to be set as CACHE BACKEND LOCATION.
#    Defaults to undef.
#
#  [*cache_server_ip*]
#    (optional) Memcached IP address. Can be a string, or an array.
#    Defaults to undef.
#
#  [*cache_server_port*]
#    (optional) Memcached port. Defaults to '11211'.
#
#  [*cache_tls_enabled*]
#    (optional) Global toggle for TLS usage when communicating with
#    the caching servers. Defaults to false.
#
#  [*cache_tls_cafile*]
#    (optional) Path to a file of concatenated CA certificates in PEM
#    format necessary to establish the caching server's authenticity.
#    If tls_enabled is False, this option is ignored.
#    Defaults to undef.
#
#  [*cache_tls_certfile*]
#    (optional) Path to a single file in PEM format containing the
#    client's certificate as well as any number of CA certificates
#    needed to establish the certificate's authenticity. This file
#    is only required when client side authentication is necessary.
#    If tls_enabled is False, this option is ignored. Defaults to undef.
#
#  [*cache_tls_keyfile*]
#    (optional) Path to a single file containing the client's private
#    key in. Otherwise the private key will be taken from the file
#    specified in tls_certfile. If tls_enabled is False, this option
#    is ignored. Defaults to undef.
#
#  [*cache_tls_allowed_ciphers*]
#    (optional) Set the available ciphers for sockets created with
#    the TLS context. It should be a string in the OpenSSL cipher
#    list format. If not specified, all OpenSSL enabled ciphers will
#    be available. Defaults to undef.
#
#  [*manage_memcache_package*]
#    (optional) Boolean if we should manage the memcache package.
#    Defaults to true
#
#  [*horizon_app_links*]
#    (optional) Array of arrays that can be used to add call-out links
#    to the dashboard for other apps. There is no specific requirement
#    for these apps to be for monitoring, that's just the de-facto purpose.
#    Each app is defined in two parts, the display name, and
#    the URIDefaults to false. Defaults to undef. (no app links)
#
#  [*keystone_url*]
#    (optional) Full url of keystone public endpoint. (Defaults to 'http://127.0.0.1:5000')
#
#  [*keystone_default_role*]
#    (optional) Default Keystone role for new users. Defaults to 'member'.
#
#  [*django_debug*]
#    (optional) Enable or disable Django debugging. Defaults to false.
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
#  [*openstack_keystone_endpoint_type*]
#    (optional) endpoint type to use for the keystone endpoint from the
#    service catalog. Defaults to 'undef'.
#
#  [*available_regions*]
#    (optional) List of available regions. Value should be a list of tuple:
#    [ ['urlOne', 'RegionOne'], ['urlTwo', 'RegionTwo'] ]
#    Defaults to undef.
#
#  [*api_result_limit*]
#    (optional) Maximum number of objects (Swift containers/objects or images)
#    to display on a single page.
#    Defaults to undef.
#
#  [*api_result_page_size*]
#    (optional) Maximum number of objects retrieved by a single request.
#    Defaults to undef.
#
#  [*dropdown_max_items*]
#    (optional) Specify a maximum number of items to display in a dropdown.
#    Defaults to undef.
#
#  [*log_handlers*]
#    (optional) Log handlers. Defaults to ['file']
#
#  [*log_level*]
#    (optional) Log level. WARNING: Setting this to DEBUG will let plaintext
#    passwords be logged in the Horizon log file.
#    Defaults to 'INFO'
#
#  [*django_log_level*]
#    (optional) Log level of django module. This overrides log_level.
#    Defaults to undef
#
#  [*django_template_log_level*]
#    (optional) Log level of django.template module.
#    Defaults to 'INFO'
#
#  [*syslog_facility*]
#    (optional) Syslog facility used when syslog log handler is enabled.
#    Defaults to 'local1'.
#
#  [*local_settings_template*]
#    (optional) Location of template to use for local_settings.py generation.
#    Defaults to 'horizon/local_settings.py.erb'.
#
#  [*help_url*]
#    (optional) Location where the documentation should point.
#    Defaults to undef
#
#  [*bug_url*]
#    (optional) If provided, a "Report Bug" link will be displayed in the site
#    header which links to the value of this setting.
#    Defaults to undef
#
#  [*compress_enabled*]
#    (optional) Boolean to enable compression.
#    Defaults to True
#
#  [*compress_offline*]
#    (optional) Boolean to enable offline compress of assets.
#    Defaults to True
#
#  [*compress_root*]
#    (optional) Absolute file path that linked static will be read from and
#    compressed static will be written to
#    Defaults to undef
#
#  [*hypervisor_options*]
#    (optional) A hash of parameters to enable features specific to
#    Hypervisors.
#    Defaults to {}
#
#  [*cinder_options*]
#    (optional) A hash of parameters to enable features specific to
#    Cinder.
#    Defaults to {}
#
#  [*keystone_options*]
#    (optional) A hash of parameters to enable features specific to
#    Keystone.
#    Defaults to {}
#
#  [*neutron_options*]
#    (optional) A hash of parameters to enable features specific to
#    Neutron.
#    Defaults to {}
#
#  [*instance_options*]
#    (optional) A hash of parameters to enable or disable instance options
#    when using the launch instance options under Compute Instances tab.
#    Defaults to {}
#
#  [*use_simple_tenant_usage*]
#    (optional) Use SimpleTenantUsage nova API in the usage overview.
#    Defaults to true.
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
#    (optional) Disable SSL hostname verifying. Set it if you don't have
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
#  [*ssl_cert*]
#    (required with listen_ssl) Certificate to use for SSL support.
#
#  [*ssl_key*]
#    (required with listen_ssl) Private key to use for SSL support.
#
#  [*ssl_ca*]
#    (required with listen_ssl) CA certificate to use for SSL support.
#
# [*ssl_verify_client*]
#   Set the Certificate verification level for Client Authentication.
#   Defaults to undef
#
#  [*wsgi_processes*]
#    (optional) Number of Horizon processes to spawn
#    Defaults to $facts['os_workers']
#
#  [*wsgi_threads*]
#    (optional) Number of thread to run in a Horizon process
#    Defaults to '1'
#
#  [*custom_wsgi_process_options*]
#    (optional) gives you the opportunity to add custom process options or to
#    overwrite the default options for the WSGI main process.
#    eg. to use a virtual python environment for the WSGI process
#    you could set it to:
#    { python-path => '/my/python/virtualenv' }
#    Defaults to {}
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
#    Default to {}
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
#    (optional) The base URL used to construct horizon web addresses.
#    Defaults to '/dashboard' or '/horizon' depending OS
#
#  [*root_path*]
#    (optional) The path to the location of static assets.
#    Defaults to "${::horizon::params::static_path}/openstack-dashboard"
#
#  [*access_log_format*]
#    (optional) The log format for the access log.
#    Defaults to undef
#
#  [*session_timeout*]
#    (optional) The session timeout for horizon in seconds. After this many
#    seconds of inactivity the user is logged out.
#    Defaults to 3600.
#
#  [*simultaneous_sessions*]
#    (optional) Controls whether a user can have multiple simultaneous
#    sessions.
#    Defaults to undef
#
#  [*token_timeout_margin*]
#    (optional) A time margin in seconds to subtract from the real token's
#    validity.
#    Defaults to 0.
#
#  [*timezone*]
#    (optional) The timezone of the server.
#    Defaults to 'UTC'.
#
#  [*available_themes*]
#    (optional) An array of hashes detailing available themes. Each hash must
#    have the followings keys for themes to be made available; name, label,
#    path. Defaults to undef
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
#    Or in Hiera:
#     horizon::available_themes:
#      - { name: 'default', label: 'Default', path: 'themes/default' }
#      - { name: 'material', label: 'Material', path: 'themes/material' }
#
#  [*default_theme*]
#    (optional) The default theme to use from list of available themes. Value
#    should be theme_name.
#    Defaults to undef
#
#  [*authentication_plugins*]
#    (optional) List of authentication plugins to be used.
#    Defaults to []
#
#  [*password_autocomplete*]
#    (optional) Whether to instruct the client browser to autofill the login form password
#    Valid values are 'on' and 'off'
#    Defaults to 'off'
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
#    The common value for this setting
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
#  [*websso_choices_hide_keystone*]
#    (optional)The WEBSSO_CHOICES option will by default include an entry for
#    "Keystone Credentials".  Setting this option to true will hide it.
#    Note that websso_initial_choice will need to be set to a valid option.
#    Default to false
#
#  [*websso_idp_mapping*]
#    (optional)Set the WEBSSO_IDP_MAPPING option.
#    A dictionary of specific identity provider and protocol combinations.
#    From the selected authentication mechanism, the value will be looked up as
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
#  [*websso_default_redirect*]
#    (optional) Enables redirection on login to the identity provider defined on
#    WEBSSO_DEFAULT_REDIRECT_PROTOCOL and WEBSSO_DEFAULT_REDIRECT_REGIO.
#    Defaults to undef
#
#  [*websso_default_redirect_protocol*]
#    (optional) Specifies the protocol to use fo default redirection on login.
#    Defaults to undef
#
#  [*websso_default_redirect_region*]
#    (optional) Specifies the region to which the connection will be established
#    on login.
#    Defaults to undef
#
#  [*websso_default_redirect_logout*]
#    (optional) Enables redirection on logout to the method specified on
#    the identity provider.
#    Defaults to undef
#
#  [*totp_enabled*]
#    (optional) Activate TOTP support.
#    Defaults to false
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
#  [*default_boot_source*]
#    (optional) A default instance boot source. Allowed values are: "image",
#    "snapshot", "volume" and "volume_snapshot".
#    Defaults to undef
#
#  [*system_scope_services*]
#    (optional) Enable the use of the system scope token on per-service basis.
#    Defaults to undef
#
#  [*show_diff*]
#    (optional) show diff changes in localsetting config file
#    Defaults to false
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
  $package_ensure                                   = 'present',
  Boolean $purge_conf_d_dir                         = false,
  Optional[Integer[0]] $memoized_max_size_default   = undef,
  $cache_backend                                    = 'django.core.cache.backends.locmem.LocMemCache',
  Hash $cache_options                               = {},
  $cache_timeout                                    = undef,
  $cache_server_url                                 = undef,
  $cache_server_ip                                  = undef,
  $cache_server_port                                = '11211',
  Boolean $cache_tls_enabled                        = false,
  $cache_tls_cafile                                 = undef,
  $cache_tls_certfile                               = undef,
  $cache_tls_keyfile                                = undef,
  $cache_tls_allowed_ciphers                        = undef,
  Boolean $manage_memcache_package                  = true,
  Array[Stdlib::HTTPUrl] $horizon_app_links         = [],
  Stdlib::HTTPUrl $keystone_url                     = 'http://127.0.0.1:5000',
  $keystone_default_role                            = 'member',
  $django_debug                                     = false,
  $site_branding                                    = undef,
  $openstack_endpoint_type                          = undef,
  $secondary_endpoint_type                          = undef,
  $openstack_keystone_endpoint_type                 = undef,
  $available_regions                                = undef,
  $api_result_limit                                 = undef,
  $api_result_page_size                             = undef,
  $dropdown_max_items                               = undef,
  Array[String[1]] $log_handlers                    = ['file'],
  $log_level                                        = 'INFO',
  $django_log_level                                 = undef,
  $django_template_log_level                        = 'INFO',
  $syslog_facility                                  = 'local1',
  Optional[Stdlib::HTTPUrl] $help_url               = undef,
  Optional[Stdlib::HTTPUrl] $bug_url                = undef,
  $local_settings_template                          = 'horizon/local_settings.py.erb',
  Boolean $configure_apache                         = true,
  $bind_address                                     = undef,
  $servername                                       = $facts['networking']['fqdn'],
  $server_aliases                                   = $facts['networking']['fqdn'],
  $allowed_hosts                                    = $facts['networking']['fqdn'],
  Boolean $listen_ssl                               = false,
  $http_port                                        = 80,
  $https_port                                       = 443,
  Boolean $ssl_no_verify                            = false,
  $openstack_ssl_cacert                             = '',
  Boolean $ssl_redirect                             = true,
  $ssl_cert                                         = undef,
  $ssl_key                                          = undef,
  $ssl_ca                                           = undef,
  $ssl_verify_client                                = undef,
  $wsgi_processes                                   = $facts['os_workers'],
  $wsgi_threads                                     = '1',
  $custom_wsgi_process_options                      = {},
  Boolean $compress_enabled                         = true,
  Boolean $compress_offline                         = true,
  Optional[Stdlib::Absolutepath] $compress_root     = undef,
  # TODO(tkajinam) Consider adding more strict validation about key-value
  Hash $hypervisor_options                          = {},
  Hash $cinder_options                              = {},
  Hash $keystone_options                            = {},
  Hash $neutron_options                             = {},
  Hash $instance_options                            = {},
  Boolean $use_simple_tenant_usage                  = true,
  Stdlib::Absolutepath $file_upload_temp_dir        = '/tmp',
  Optional[Stdlib::Absolutepath] $policy_files_path = undef,
  Optional[Hash[String, String]] $policy_files      = undef,
  $redirect_type                                    = 'permanent',
  Hash $api_versions                                = {},
  Boolean $keystone_multidomain_support             = false,
  $keystone_default_domain                          = undef,
  $keystone_domain_choices                          = undef,
  Hash[String, Hash[String, String]] $image_backend = {},
  $overview_days_range                              = undef,
  $root_url                                         = $::horizon::params::root_url,
  Stdlib::Absolutepath $root_path                   = "${::horizon::params::static_path}/openstack-dashboard",
  $access_log_format                                = undef,
  $session_timeout                                  = 3600,
  $token_timeout_margin                             = 0,
  $simultaneous_sessions                            = undef,
  $timezone                                         = 'UTC',
  Boolean $secure_cookies                           = false,
  $django_session_engine                            = undef,
  $vhost_extra_params                               = undef,
  Horizon::AvailableThemes $available_themes        = undef,
  Optional[String[1]] $default_theme                = undef,
  Array[String[1]] $authentication_plugins          = [],
  Enum['on', 'off'] $password_autocomplete          = 'off',
  $create_image_defaults                            = undef,
  Boolean $password_retrieve                        = false,
  Boolean $disable_password_reveal                  = false,
  Boolean $enforce_password_check                   = false,
  Boolean $enable_secure_proxy_ssl_header           = false,
  $secure_proxy_addr_header                         = undef,
  Boolean $disallow_iframe_embed                    = true,
  Boolean $websso_enabled                           = false,
  $websso_initial_choice                            = undef,
  $websso_choices                                   = undef,
  Boolean $websso_choices_hide_keystone             = false,
  $websso_idp_mapping                               = undef,
  Boolean $websso_default_redirect                  = false,
  $websso_default_redirect_protocol                 = undef,
  $websso_default_redirect_region                   = undef,
  $websso_default_redirect_logout                   = undef,
  Boolean $totp_enabled                             = false,
  $password_validator                               = undef,
  $password_validator_help                          = undef,
  $customization_module                             = undef,
  $horizon_upload_mode                              = undef,
  $default_boot_source                              = undef,
  $system_scope_services                            = undef,
  Boolean $show_diff                                = false,
) inherits horizon::params {

  include horizon::deps

  if $cache_server_url and $cache_server_ip {
    fail('Only one of cache_server_url or cache_server_ip can be set.')
  }

  if $cache_server_ip {
    if $cache_backend =~ /\.MemcachedCache$/ {
      $cache_server_ip_real = inet6_prefix($cache_server_ip)
    } else {
      $cache_server_ip_real = normalize_ip_for_uri($cache_server_ip)
    }
  }

  if $websso_choices_hide_keystone and !$websso_initial_choice {
    fail('websso_initial_choice is required when websso_choices_hide_keystone is true')
  }

  if $available_themes {
    validate_available_themes($available_themes)
  }

  Service <| title == 'memcached' |> -> Class['horizon']

  if $policy_files_path != undef {
    $policy_files_path_real = $policy_files_path
  } else {
    $policy_files_path_real = $::horizon::params::policy_dir
  }

  if $manage_memcache_package {
    if $cache_backend =~ /\.MemcachedCache$/ {
      warning("Support for MemcachedCache backend has been deprecated. \
Use PyMemcacheCache backend instead")
      ensure_packages('python-memcache', {
        name => $::horizon::params::memcache_package,
        tag  => ['openstack'],
      })
      Anchor['horizon::install::begin']
        -> Package<| name == $::horizon::params::memcache_package |>
        -> Anchor['horizon::install::end']

    } elsif $cache_backend =~ /\.PyMemcacheCache$/ {
      ensure_packages('python-pymemcache', {
        name => $::horizon::params::pymemcache_package,
        tag  => ['openstack'],
      })
      Anchor['horizon::install::begin']
        -> Package<| name == $::horizon::params::pymemcache_package |>
        -> Anchor['horizon::install::end']
    } elsif $cache_backend =~ /\.RedisCache$/ {
      ensure_packages('python-redis', {
        name => $::horizon::params::python_redis_package,
        tag  => ['openstack'],
      })
      Anchor['horizon::install::begin']
        -> Package<| name == $::horizon::params::python_redis_package |>
        -> Anchor['horizon::install::end']
    }
  }

  $django_log_level_real = pick($django_log_level, $log_level)

  package { 'horizon':
    ensure => $package_ensure,
    name   => $::horizon::params::package_name,
    tag    => ['openstack', 'horizon-package'],
  }

  $secret_key_path = "${::horizon::params::config_dir}/.secret_key_store"
  file { $secret_key_path:
    mode      => '0600',
    content   => $secret_key,
    owner     => $::horizon::params::wsgi_user,
    group     => $::horizon::params::wsgi_group,
    show_diff => false,
    require   => Anchor['horizon::config::begin'],
    notify    => Anchor['horizon::config::end'],
  }

  concat { $::horizon::params::config_file:
    mode      => '0640',
    owner     => $::horizon::params::wsgi_user,
    group     => $::horizon::params::wsgi_group,
    show_diff => $show_diff,
    tag       => ['django-config'],
  }

  concat::fragment { 'local_settings.py':
    target  => $::horizon::params::config_file,
    content => template($local_settings_template),
    order   => '50',
  }

  file { $::horizon::params::conf_d_dir:
    ensure  => 'directory',
    mode    => '0755',
    purge   => $purge_conf_d_dir,
    recurse => $purge_conf_d_dir,
    owner   => $::horizon::params::wsgi_user,
    group   => $::horizon::params::wsgi_group,
    require => Anchor['horizon::config::begin'],
  }

  if $compress_offline {
    if $facts['os']['family'] == 'Debian' {
      exec { 'refresh_horizon_django_compress':
        command     => "${::horizon::params::manage_py} compress --force",
        refreshonly => true,
        tag         => ['horizon-compress'],
      }
    }
  }

  if $configure_apache {
    class { 'horizon::wsgi::apache':
      bind_address                => $bind_address,
      servername                  => $servername,
      server_aliases              => $server_aliases,
      listen_ssl                  => $listen_ssl,
      http_port                   => $http_port,
      https_port                  => $https_port,
      ssl_redirect                => $ssl_redirect,
      ssl_cert                    => $ssl_cert,
      ssl_key                     => $ssl_key,
      ssl_ca                      => $ssl_ca,
      ssl_verify_client           => $ssl_verify_client,
      wsgi_processes              => $wsgi_processes,
      wsgi_threads                => $wsgi_threads,
      custom_wsgi_process_options => $custom_wsgi_process_options,
      extra_params                => $vhost_extra_params,
      redirect_type               => $redirect_type,
      root_url                    => $root_url,
      root_path                   => $root_path,
      access_log_format           => $access_log_format,
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
