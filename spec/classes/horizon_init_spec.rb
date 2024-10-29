require 'spec_helper'

describe 'horizon' do

  let :params do
    { 'secret_key' => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0' }
  end

  let :pre_condition do
    'include apache'
  end

  let :fixtures_path do
    File.expand_path(File.join(__FILE__, '..', '..', 'fixtures'))
  end

  shared_examples_for 'horizon' do

    context 'with default parameters' do
      it {
          is_expected.to contain_package('horizon').with(
            :ensure => 'present',
            :tag    => ['openstack', 'horizon-package'],
          )
      }

      it {
        is_expected.to contain_concat(platforms_params[:config_file]).with(
          :mode      => '0640',
          :owner     => platforms_params[:wsgi_user],
          :group     => platforms_params[:wsgi_group],
          :show_diff => false,
        )
      }

      it 'configures apache' do
        is_expected.to contain_class('horizon::wsgi::apache').with({
          :servername                  => 'foo.example.com',
          :listen_ssl                  => false,
          :wsgi_processes              => facts[:os_workers],
          :wsgi_threads                => '1',
          :custom_wsgi_process_options => {},
          :extra_params                => {},
          :redirect_type               => 'permanent',
        })
      end

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'DEBUG = False',
          "ALLOWED_HOSTS = ['foo.example.com', ]",
          'HORIZON_CONFIG["password_autocomplete"] = "off"',
          "SECRET_KEY = secret_key.generate_or_read_from_file('#{platforms_params[:secret_key_file]}')",
          'OPENSTACK_KEYSTONE_URL = "http://127.0.0.1:5000"',
          'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "member"',
          'TIME_ZONE = "UTC"',
          "            'handlers': ['file'],",
          'SESSION_TIMEOUT = 3600',
          'TOKEN_TIMEOUT_MARGIN = 0',
          'COMPRESS_ENABLED = True',
          'COMPRESS_OFFLINE = True',
          "FILE_UPLOAD_TEMP_DIR = '/tmp'",
        ])

        # From internals of verify_contents, get the contents to check for absence of a line
        content = catalogue.resource('concat::fragment', 'local_settings.py').send(:parameters)[:content]

        # With default options, should _not_ have a line to configure SESSION_ENGINE
        expect(content).not_to match(/^SESSION_ENGINE/)
      end

      it { is_expected.to contain_file(platforms_params[:conf_d_dir]).with(
        :ensure  => 'directory',
        :mode    => '0755',
        :purge   => false,
        :recurse => false,
        :owner   => platforms_params[:wsgi_user],
        :group   => platforms_params[:wsgi_group],
      ) }

      it 'creates a key file' do
        is_expected.to contain_file(platforms_params[:secret_key_file]).with(
          :mode      => '0600',
          :content   => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          :owner     => platforms_params[:wsgi_user],
          :group     => platforms_params[:wsgi_group],
          :show_diff => false,
        )
      end
      it { is_expected.not_to contain_file('/tmp') }
    end

    context 'with overridden parameters' do
      before do
        params.merge!({
          :purge_conf_d_dir                 => true,
          :memoized_max_size_default        => 25,
          :cache_backend                    => 'django.core.cache.backends.memcached.MemcachedCache',
          :cache_timeout                    => 300,
          :cache_options                    => {'SOCKET_TIMEOUT' => 1,'SERVER_RETRIES' => 1,'DEAD_RETRY' => 1},
          :cache_server_ip                  => '10.0.0.1',
          :django_session_engine            => 'django.contrib.sessions.backends.cache',
          :keystone_default_role            => 'SwiftOperator',
          :keystone_url                     => 'https://keystone.example.com:4682',
          :ssl_no_verify                    => true,
          :log_handlers                     => ['console', 'syslog'],
          :log_level                        => 'DEBUG',
          :openstack_endpoint_type          => 'internalURL',
          :secondary_endpoint_type          => 'ANY-VALUE',
          :openstack_keystone_endpoint_type => 'public',
          :django_debug                     => true,
          :site_branding                    => 'mysite',
          :api_result_limit                 => 2000,
          :api_result_page_size             => 40,
          :dropdown_max_items               => 123,
          :compress_enabled                 => false,
          :compress_offline                 => false,
          :compress_root                    => '/tmp',
          :hypervisor_options               => {'can_set_mount_point' => false, 'can_set_password' => true },
          :cinder_options                   => {'enable_backup' => true },
          :keystone_options                 => {'name' => 'native', 'can_edit_user' => true, 'can_edit_group' => true, 'can_edit_project' => true, 'can_edit_domain' => false, 'can_edit_role' => false},
          :neutron_options                  => {'enable_quotas' => false, 'enable_security_group' => false, 'enable_distributed_router' => false, 'enable_ha_router' => false,
                                                'supported_provider_types' => ['flat', 'vxlan'], 'supported_vnic_types' => ['*'], 'default_ipv4_subnet_pool_label' => 'None', },
          :instance_options                 => {'disable_image' => true, 'disable_instance_snapshot' => true, 'disable_volume' => true, 'disable_volume_snapshot' => true, 'create_volume' => false },
          :file_upload_temp_dir             => '/var/spool/horizon',
          :wsgi_processes                   => '30',
          :wsgi_threads                     => '5',
          :secure_cookies                   => true,
          :api_versions                     => {'identity' => 3},
          :keystone_multidomain_support     => true,
          :keystone_default_domain          => 'domain.tld',
          :overview_days_range              => 1,
          :session_timeout                  => 1800,
          :simultaneous_sessions            => 'allow',
          :token_timeout_margin             => 60,
          :timezone                         => 'Asia/Shanghai',
          :available_themes                 => [
            { 'name' => 'default', 'label' => 'Default', 'path' => 'themes/default' },
            { 'name' => 'material', 'label' => 'Material', 'path' => 'themes/material' },
          ],
          :default_theme                    => 'default',
          :password_autocomplete            => 'on',
          :create_image_defaults            => {'image_visibility' => 'private'},
          :password_retrieve                => true,
          :enable_secure_proxy_ssl_header   => true,
          :secure_proxy_addr_header         => 'HTTP_X_FORWARDED_FOR',
          :show_diff                        => true,
        })
      end

      it {
        is_expected.to contain_concat(platforms_params[:config_file]).with(
          :mode      => '0640',
          :owner     => platforms_params[:wsgi_user],
          :group     => platforms_params[:wsgi_group],
          :show_diff => true,
        )
      }

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'DEBUG = True',
          "SITE_BRANDING = 'mysite'",
          "ALLOWED_HOSTS = ['foo.example.com', ]",
          "SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')",
          "SECURE_PROXY_ADDR_HEADER = 'HTTP_X_FORWARDED_FOR'",
          'CSRF_COOKIE_SECURE = True',
          'SESSION_COOKIE_SECURE = True',
          'SESSION_COOKIE_HTTPONLY = True',
          "    'identity': 3,",
          "OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True",
          "OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'domain.tld'",
          'HORIZON_CONFIG["password_autocomplete"] = "on"',
          "        'OPTIONS': {",
          "            'DEAD_RETRY': 1,",
          "            'SERVER_RETRIES': 1,",
          "            'SOCKET_TIMEOUT': 1,",
          "MEMOIZED_MAX_SIZE_DEFAULT = 25",
          "        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',",
          "        'LOCATION': '10.0.0.1:11211',",
          "        'TIMEOUT': 300,",
          'SESSION_ENGINE = "django.contrib.sessions.backends.cache"',
          'OPENSTACK_KEYSTONE_URL = "https://keystone.example.com:4682"',
          'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "SwiftOperator"',
          'OPENSTACK_SSL_NO_VERIFY = True',
          'from openstack_dashboard.settings import OPENSTACK_KEYSTONE_BACKEND',
          'OPENSTACK_KEYSTONE_BACKEND.update({',
          "    'name': 'native',",
          "    'can_edit_user': True,",
          "    'can_edit_group': True,",
          "    'can_edit_project': True,",
          "    'can_edit_domain': False,",
          "    'can_edit_role': False,",
          'from openstack_dashboard.settings import OPENSTACK_HYPERVISOR_FEATURES',
          'OPENSTACK_HYPERVISOR_FEATURES.update({',
          "    'can_set_mount_point': False,",
          "    'can_set_password': True,",
          'from openstack_dashboard.settings import OPENSTACK_CINDER_FEATURES',
          'OPENSTACK_CINDER_FEATURES.update({',
          "    'enable_backup': True,",
          'from openstack_dashboard.settings import OPENSTACK_NEUTRON_NETWORK',
          'OPENSTACK_NEUTRON_NETWORK.update({',
          "    'default_ipv4_subnet_pool_label': None,",
          "    'enable_quotas': False,",
          "    'enable_security_group': False,",
          "    'enable_distributed_router': False,",
          "    'enable_ha_router': False,",
          "    'supported_provider_types': ['flat', 'vxlan'],",
          "    'supported_vnic_types': ['*'],",
          'OPENSTACK_ENABLE_PASSWORD_RETRIEVE = True',
          'from openstack_dashboard.settings import CREATE_IMAGE_DEFAULTS',
          'CREATE_IMAGE_DEFAULTS.update({',
          "    'image_visibility': 'private',",
          "    'create_volume': False,",
          "    'disable_image': True,",
          "    'disable_instance_snapshot': True,",
          "    'disable_volume': True,",
          "    'disable_volume_snapshot': True,",
          'OPENSTACK_ENDPOINT_TYPE = "internalURL"',
          'SECONDARY_ENDPOINT_TYPE = "ANY-VALUE"',
          'OPENSTACK_KEYSTONE_ENDPOINT_TYPE = "public"',
          'API_RESULT_LIMIT = 2000',
          'API_RESULT_PAGE_SIZE = 40',
          'DROPDOWN_MAX_ITEMS = 123',
          'TIME_ZONE = "Asia/Shanghai"',
          'AVAILABLE_THEMES = [',
          "    ('default', 'Default', 'themes/default'),",
          "    ('material', 'Material', 'themes/material'),",
          ']',
          "DEFAULT_THEME = 'default'",
          "            'level': 'DEBUG',",
          "            'handlers': ['console', 'syslog'],",
          'SESSION_TIMEOUT = 1800',
          "SIMULTANEOUS_SESSIONS = 'allow'",
          'TOKEN_TIMEOUT_MARGIN = 60',
          'COMPRESS_ENABLED = False',
          'COMPRESS_OFFLINE = False',
          "COMPRESS_ROOT = '/tmp'",
          "FILE_UPLOAD_TEMP_DIR = '/var/spool/horizon'",
          'OVERVIEW_DAYS_RANGE = 1',
          'DISALLOW_IFRAME_EMBED = True',
        ])
      end

      it { is_expected.to contain_file(platforms_params[:conf_d_dir]).with(
        :ensure  => 'directory',
        :mode    => '0755',
        :purge   => true,
        :recurse => true,
        :owner   => platforms_params[:wsgi_user],
        :group   => platforms_params[:wsgi_group],
      ) }
      it { is_expected.to_not contain_exec('refresh_horizon_django_compress') }

      it { is_expected.to contain_file(params[:file_upload_temp_dir]) }
    end

    context 'with overridden parameters and cache_server_ip array' do
      before do
        params.merge!({
          :cache_server_ip => ['10.0.0.1','10.0.0.2'],
        })
      end

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "        'LOCATION': [ '10.0.0.1:11211','10.0.0.2:11211', ],",
        ])
      end
    end

    context 'with overridden parameters, IPv6 cache_server_ip array and MemcachedCache' do
      before do
        params.merge!({
          :cache_backend   => 'django.core.cache.backends.memcached.MemcachedCache',
          :cache_server_ip => ['fd12:3456:789a:1::1','fd12:3456:789a:1::2'],
        })
      end

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',",
          "        'LOCATION': [ 'inet6:[fd12:3456:789a:1::1]:11211','inet6:[fd12:3456:789a:1::2]:11211', ],",
        ])
      end
    end

    context 'with overridden parameters, IPv6 cache_server_ip array and PyMemcacheCache' do
      before do
        params.merge!({
          :cache_backend   => 'django.core.cache.backends.memcached.PyMemcacheCache',
          :cache_server_ip => ['fd12:3456:789a:1::1','fd12:3456:789a:1::2'],
        })
      end

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "        'BACKEND': 'django.core.cache.backends.memcached.PyMemcacheCache',",
          "        'LOCATION': [ '[fd12:3456:789a:1::1]:11211','[fd12:3456:789a:1::2]:11211', ],",
        ])
      end
    end

    context 'with overridden parameters and cache_server_url (string)' do
      before do
        params.merge!({
          :cache_server_url => 'redis://:password@10.0.0.1:6379/1',
        })
      end

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "        'LOCATION': 'redis://:password@10.0.0.1:6379/1',",
        ])
      end
    end

    context 'with overridden parameters and cache_server_url (array)' do
      before do
        params.merge!({
          :cache_server_url => ['192.0.2.1:11211', '192.0.2.2:11211'],
        })
      end

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "        'LOCATION': ['192.0.2.1:11211','192.0.2.2:11211'],",
        ])
      end
    end

    context 'installs python memcache library when cache_backend is set to memcache' do
      before do
        params.merge!({
          :cache_backend => 'django.core.cache.backends.memcached.MemcachedCache'
        })
      end

      it {
        is_expected.to contain_package('python-memcache').with(
          :tag    => ['openstack'],
          :name   => platforms_params[:memcache_package],
        )
      }
    end

    context 'does not install python memcache when manage_memcache_package set to false' do
      before do
        params.merge!({
          :cache_backend           => 'django.core.cache.backends.memcached.MemcachedCache',
          :manage_memcache_package => false
        })
      end

      it { is_expected.not_to contain_package('python-memcache') }
    end

    context 'installs python memcache library when cache_backend is set to pymemcache' do
      before do
        params.merge!({
          :cache_backend => 'django.core.cache.backends.memcached.PyMemcacheCache'
        })
      end

      it {
        is_expected.to contain_package('python-pymemcache').with(
          :tag    => ['openstack'],
          :name   => platforms_params[:pymemcache_package],
        )
      }
    end

    context 'does not install python memcache when manage_memcache_package set to false' do
      before do
        params.merge!({
          :cache_backend           => 'django.core.cache.backends.memcached.PyMemcacheCache',
          :manage_memcache_package => false
        })
      end

      it { is_expected.not_to contain_package('python-pymemcache') }
    end

    context 'installs python redis library when cache_backend is set to redis' do
      before do
        params.merge!({
          :cache_backend => 'django.core.cache.backends.redis.RedisCache',
        })
      end

      it {
        is_expected.to contain_package('python-redis').with(
          :tag    => ['openstack'],
          :name   => platforms_params[:python_redis_package],
        )
      }
    end

    context 'does not install python redis when manage_memcache_package set to false' do
      before do
        params.merge!({
          :cache_backend           => 'django.core.cache.backends.redis.RedisCache',
          :manage_memcache_package => false
        })
      end

      it { is_expected.not_to contain_package('python-redis') }
    end

    context 'with custom wsgi options' do
      before do
        params.merge!( :wsgi_processes              => '30',
                       :wsgi_threads                => '5',
                       :custom_wsgi_process_options => { 'python-env' => '/tmp/test' },
                       :access_log_format           => 'common' )
      end

      it { should contain_class('horizon::wsgi::apache').with(
        :wsgi_processes              => '30',
        :wsgi_threads                => '5',
        :custom_wsgi_process_options => { 'python-env' => '/tmp/test' },
        :access_log_format           => 'common',
      )}
    end

    context 'with vhost_extra_params' do
      before do
        params.merge!({
          :vhost_extra_params => { 'add_listen' => false },
          :redirect_type      => 'temp',
        })
      end

      it 'configures apache' do
        is_expected.to contain_class('horizon::wsgi::apache').with({
          :extra_params  => { 'add_listen' => false },
          :redirect_type => 'temp',
        })
      end
    end

    context 'with ssl enabled' do
      before do
        params.merge!({
          :listen_ssl        => true,
          :servername        => 'foo.example.com',
          :ssl_cert          => '/etc/pki/tls/certs/httpd.crt',
          :ssl_key           => '/etc/pki/tls/private/httpd.key',
          :ssl_ca            => '/etc/pki/tls/certs/ca.crt',
          :ssl_verify_client => 'optional',
        })
      end

      it 'configures apache' do
        is_expected.to contain_class('horizon::wsgi::apache').with({
          :bind_address      => nil,
          :listen_ssl        => true,
          :ssl_cert          => '/etc/pki/tls/certs/httpd.crt',
          :ssl_key           => '/etc/pki/tls/private/httpd.key',
          :ssl_ca            => '/etc/pki/tls/certs/ca.crt',
          :ssl_verify_client => 'optional',
        })
      end
    end

    context 'with overridden http and https ports' do
      before do
        params.merge!({
          :http_port  => 1028,
          :https_port => 1029,
        })
      end

      it 'configures apache' do
        is_expected.to contain_class('horizon::wsgi::apache').with({
          :http_port  => 1028,
          :https_port => 1029,
        })
      end
    end

    context 'with default root_path' do
      it 'configures apache' do
        is_expected.to contain_class('horizon::wsgi::apache').with({
          :root_path    => "#{platforms_params[:root_path]}",
        })
      end
    end

    context 'with root_path set to /tmp/horizon' do
      before do
        params.merge!({
          :root_path    => '/tmp/horizon',
        })
      end

      it 'configures apache' do
        is_expected.to contain_class('horizon::wsgi::apache').with({
          :root_path    => '/tmp/horizon',
        })
      end
    end

    context 'without apache' do
      before do
        params.merge!({ :configure_apache => false })
      end

      it 'does not configure apache' do
        is_expected.not_to contain_class('horizon::wsgi::apache')
      end
    end

    context 'with available_regions parameter' do
      before do
        params.merge!({
          :available_regions => [
            ['http://region-1.example.com:5000', 'Region-1'],
            ['http://region-2.example.com:5000', 'Region-2']
          ]
        })
      end

      it 'AVAILABLE_REGIONS is configured' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "AVAILABLE_REGIONS = [",
          "    ('http://region-1.example.com:5000', 'Region-1'),",
          "    ('http://region-2.example.com:5000', 'Region-2'),",
          "]"
        ])
      end
    end

    context 'with policy parameters' do
      before do
        params.merge!({
          :policy_files_path => '/opt/openstack-dashboard',
          :policy_files      => {
            'compute'  => 'nova_policy.json',
            'identity' => 'keystone_policy.json',
            'network'  => 'neutron_policy.json',
          }
        })
      end

      it 'POLICY_FILES_PATH and POLICY_FILES are configured' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "POLICY_FILES_PATH = '/opt/openstack-dashboard'",
          "POLICY_FILES = {",
          "    'compute': 'nova_policy.json',",
          "    'identity': 'keystone_policy.json',",
          "    'network': 'neutron_policy.json',",
          "} # POLICY_FILES"
        ])
      end
    end

    context 'with overriding local_settings_template' do
      before do
        params.merge!({
          :django_debug            => 'True',
          :help_url                => 'https://docs.openstack.org',
          :local_settings_template => fixtures_path + '/override_local_settings.py.erb'
        })
      end

      it 'uses the custom local_settings.py template' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          '# Custom local_settings.py',
          'DEBUG = True',
          'HORIZON_CONFIG["help_url"] = "https://docs.openstack.org"',
        ])
      end
    end

    context 'with /var/tmp as upload temp dir' do
      before do
        params.merge!({
          :file_upload_temp_dir => '/var/tmp'
        })
      end

      it { is_expected.not_to contain_file(params[:file_upload_temp_dir]) }
    end

    context 'with image_backend' do
      before do
        params.merge!({
          :image_backend => {
            'image_formats' => {
              ''      => 'Select image format',
              'aki'   => 'AKI - Amazon Kernel Image',
              'ami'   => 'AMI - Amazon Machine Image',
              'ari'   => 'ARI - Amazon Ramdisk Image',
              'iso'   => 'ISO - Optical Disk Image',
              'qcow2' => 'QCOW2 - QEMU Emulator',
              'raw'   => 'Raw',
              'vdi'   => 'VDI',
              'vhi'   => 'VHI',
              'vmdk'  => 'VMDK',
            },
            'architectures' => {
              ''        => 'Select architecture',
              'x86_64'  => 'x86-64',
              'aarch64' => 'ARMv8',
            },
          },
        })
      end

      it 'configures OPENSTACK_IMAGE_BACKEND' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "OPENSTACK_IMAGE_BACKEND = {",
          "    'image_formats': [",
          "        ('', _('Select image format')),",
          "        ('aki', _('AKI - Amazon Kernel Image')),",
          "        ('ami', _('AMI - Amazon Machine Image')),",
          "        ('ari', _('ARI - Amazon Ramdisk Image')),",
          "        ('iso', _('ISO - Optical Disk Image')),",
          "        ('qcow2', _('QCOW2 - QEMU Emulator')),",
          "        ('raw', _('Raw')),",
          "        ('vdi', _('VDI')),",
          "        ('vhi', _('VHI')),",
          "        ('vmdk', _('VMDK')),",
          "    ], # image_formats",
          "    'architectures': [",
          "        ('', _('Select architecture')),",
          "        ('x86_64', _('x86-64')),",
          "        ('aarch64', _('ARMv8')),",
          "    ], # architectures",
          "} # OPENSTACK_IMAGE_BACKEND",
        ])
      end
    end

    context 'with disable password reveal enabled' do
      before do
        params.merge!({
          :disable_password_reveal => true
        })
      end

      it 'disable_password_reveal is configured' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'HORIZON_CONFIG["disable_password_reveal"] = True',
        ])
      end
    end

    context 'with enforce password check enabled' do
      before do
        params.merge!({
          :enforce_password_check => true
        })
      end

      it 'enforce_password_check is configured' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'ENFORCE_PASSWORD_CHECK = True',
        ])
      end
    end

    context 'with disallow iframe embed disabled' do
      before do
        params.merge!({
                        :disallow_iframe_embed => false
                      })
      end

      it 'disallow_iframe_embed is configured' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
                                          'DISALLOW_IFRAME_EMBED = False',
                                        ])
      end
    end

    context 'with websso enabled' do
      before do
        params.merge!({
            :websso_enabled        => true,
            :websso_initial_choice => 'acme',
            :websso_choices        => [
              ['oidc', 'OpenID Connect'],
              ['saml2', 'Security Assertion Markup Language'],
            ],
            :websso_idp_mapping    => {
              'acme_oidc'  => ['acme', 'oidc'],
              'acme_saml2' => ['acme', 'saml2'],
            }
          })
      end
      it 'configures websso options' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'WEBSSO_ENABLED = True',
          'WEBSSO_INITIAL_CHOICE = "acme"',
          'WEBSSO_CHOICES = (',
          '    ("credentials", _("Keystone Credentials")),',
          '    ("oidc", _("OpenID Connect")),',
          '    ("saml2", _("Security Assertion Markup Language")),',
          ')',
          'WEBSSO_IDP_MAPPING = {',
          '    "acme_oidc": ("acme", "oidc"),',
          '    "acme_saml2": ("acme", "saml2"),',
          '}',
          ])
      end
    end

    context 'with websso redirect enabled' do
      before do
        params.merge!({
          :websso_default_redirect          => true,
          :websso_default_redirect_protocol => 'oidc',
          :websso_default_redirect_region   => 'http://127.0.0.1:5000',
          :websso_default_redirect_logout   => 'http://idptest/logout'
        })
      end
      it 'configures websso redirect options' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'WEBSSO_DEFAULT_REDIRECT = True',
          'WEBSSO_DEFAULT_REDIRECT_PROTOCOL = "oidc"',
          'WEBSSO_DEFAULT_REDIRECT_REGION = "http://127.0.0.1:5000"',
          'WEBSSO_DEFAULT_REDIRECT_LOGOUT = "http://idptest/logout"'
          ])
      end
    end

    context 'with totp enabled' do
      before do
        params.merge!({
          :totp_enabled           => true,
          :authentication_plugins => [
            'openstack_auth.plugin.totp.TotpPlugin',
            'openstack_auth.plugin.password.PasswordPlugin',
            'openstack_auth.plugin.token.TokenPlugin'
          ]
        })
      end
      it 'configures totp options' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'OPENSTACK_KEYSTONE_MFA_TOTP_ENABLED = True',
          'AUTHENTICATION_PLUGINS = [',
          "    'openstack_auth.plugin.totp.TotpPlugin',",
          "    'openstack_auth.plugin.password.PasswordPlugin',",
          "    'openstack_auth.plugin.token.TokenPlugin',",
          ])
      end
    end

    context 'with horizon_app_links' do
      before do
        params.merge!({
          :horizon_app_links => [
            'https://monitoring1.example.com',
            'https://monitoring2.example.com'
          ]
        })
      end

      it 'configures EXTERNAL_MONITORING' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          "EXTERNAL_MONITORING = ['https://monitoring1.example.com', 'https://monitoring2.example.com']",
        ])
      end
    end

    context 'with help_url, bug_url and customization_module provided' do
      before do
        params.merge!({
          :help_url             => 'https://docs.openstack.org',
          :bug_url              => 'https://bugs.launchpad.net',
          :customization_module => 'my_project.overrides',
        })
      end

      it 'configures all options' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'HORIZON_CONFIG["help_url"] = "https://docs.openstack.org"',
          'HORIZON_CONFIG["bug_url"] = "https://bugs.launchpad.net"',
          'HORIZON_CONFIG["customization_module"] = "my_project.overrides"',
        ])
      end
    end

    context 'with upload mode' do
      before do
        params.merge!({
          :horizon_upload_mode  => 'direct',
        })
      end
      it 'sets HORIZON_IMAGES_UPLOAD_MODE in local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'HORIZON_IMAGES_UPLOAD_MODE = "direct"',
        ])
      end
    end

    context 'with keystone_domain_choices' do
      before do
        params.merge!({
          :keystone_domain_choices  => [
            {'name' => 'default', 'display' => 'The default domain'},
            {'name' => 'LDAP', 'display' => 'The LDAP Catalog'},
          ],
        })
      end
      it 'sets OPENSTACK_KEYSTONE_DOMAIN_DROPDOWN in local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'OPENSTACK_KEYSTONE_DOMAIN_DROPDOWN = True',
          'OPENSTACK_KEYSTONE_DOMAIN_CHOICES = (',
          "    ('default', 'The default domain'),",
          "    ('LDAP', 'The LDAP Catalog'),",
          ')',
        ])
      end
    end
  end

  shared_examples_for 'horizon on RedHat' do
    it 'skips refreshing horizon django cache' do
      is_expected.to_not contain_exec('refresh_horizon_django_compress')
    end

    it 'sets WEBROOT in local_settings.py' do
      verify_concat_fragment_contents(catalogue, 'local_settings.py', [
        "WEBROOT = '/dashboard'",
      ])
    end
  end

  shared_examples_for 'horizon on Debian' do
    it 'refreshes horizon django cache' do
      is_expected.to contain_exec('refresh_horizon_django_compress').with({
        :command     => '/usr/share/openstack-dashboard/manage.py compress --force',
        :refreshonly => true,
      })
      is_expected.to contain_concat(platforms_params[:config_file]).that_notifies('Exec[refresh_horizon_django_compress]')
    end

    it 'sets WEBROOT in local_settings.py' do
      verify_concat_fragment_contents(catalogue, 'local_settings.py', [
        "WEBROOT = '/horizon'",
      ])
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platforms_params) do
        case facts[:os]['family']
        when 'Debian'
          if facts[:os]['name'] == 'Debian'
            { :config_file          => '/etc/openstack-dashboard/local_settings.py',
              :conf_d_dir           => '/etc/openstack-dashboard/local_settings.d',
              :secret_key_file      => '/etc/openstack-dashboard/.secret_key_store',
              :package_name         => 'openstack-dashboard-apache',
              :root_url             => '/horizon',
              :root_path            => '/var/lib/openstack-dashboard',
              :memcache_package     => 'python3-memcache',
              :pymemcache_package   => 'python3-pymemcache',
              :python_redis_package => 'python3-redis',
              :wsgi_user            => 'horizon',
              :wsgi_group           => 'horizon',
            }
          else
            { :config_file          => '/etc/openstack-dashboard/local_settings.py',
              :conf_d_dir           => '/etc/openstack-dashboard/local_settings.d',
              :secret_key_file      => '/etc/openstack-dashboard/.secret_key_store',
              :package_name         => 'openstack-dashboard',
              :root_url             => '/horizon',
              :root_path            => '/var/lib/openstack-dashboard',
              :memcache_package     => 'python3-memcache',
              :pymemcache_package   => 'python3-pymemcache',
              :python_redis_package => 'python3-redis',
              :wsgi_user            => 'horizon',
              :wsgi_group           => 'horizon',
            }
          end
        when 'RedHat'
          { :config_file          => '/etc/openstack-dashboard/local_settings',
            :conf_d_dir           => '/etc/openstack-dashboard/local_settings.d',
            :secret_key_file      => '/etc/openstack-dashboard/.secret_key_store',
            :package_name         => 'openstack-dashboard',
            :root_url             => '/dashboard',
            :root_path            => '/usr/share/openstack-dashboard',
            :memcache_package     => 'python3-memcached',
            :pymemcache_package   => 'python3-pymemcache',
            :python_redis_package => 'python3-redis',
            :wsgi_user            => 'apache',
            :wsgi_group           => 'apache',
          }
        end
      end

      it_behaves_like 'horizon'
      it_behaves_like "horizon on #{facts[:os]['family']}"
    end
  end
end
