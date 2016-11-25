require 'spec_helper'

describe 'horizon' do

  let :params do
    { 'secret_key' => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
      'fqdn'       => '*' }
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
      it { is_expected.to contain_exec('refresh_horizon_django_cache').with({
          :command     => '/usr/share/openstack-dashboard/manage.py collectstatic --noinput --clear',
          :refreshonly => true,
      })}
      it { is_expected.to contain_exec('refresh_horizon_django_compress').with({
          :command     => '/usr/share/openstack-dashboard/manage.py compress --force',
          :refreshonly => true,
      })}
      it {
        if facts[:os_package_type] == 'rpm'
          is_expected.to contain_concat(platforms_params[:config_file]).that_notifies('Exec[refresh_horizon_django_cache]')
          is_expected.to contain_concat(platforms_params[:config_file]).that_notifies('Exec[refresh_horizon_django_compress]')
        else
          is_expected.to_not contain_concat(platforms_params[:config_file]).that_notifies('Exec[refresh_horizon_django_cache]')
          is_expected.to contain_concat(platforms_params[:config_file]).that_notifies('Exec[refresh_horizon_django_compress]')
        end
      }

      it 'configures apache' do
        is_expected.to contain_class('horizon::wsgi::apache').with({
          :servername    => 'some.host.tld',
          :listen_ssl    => false,
          :extra_params  => {},
          :redirect_type => 'permanent',
        })
      end

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'DEBUG = False',
          "LOGIN_URL = '#{platforms_params[:root_url]}/auth/login/'",
          "LOGOUT_URL = '#{platforms_params[:root_url]}/auth/logout/'",
          "LOGIN_REDIRECT_URL = '#{platforms_params[:root_url]}/'",
          "ALLOWED_HOSTS = ['*', ]",
          "  'identity': 3,",
          'HORIZON_CONFIG["password_autocomplete"] = "off"',
          'HORIZON_CONFIG["images_panel"] = "legacy"',
          "SECRET_KEY = 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0'",
          'OPENSTACK_KEYSTONE_URL = "http://127.0.0.1:5000"',
          'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"',
          "    'can_set_mount_point': True,",
          "    'can_set_password': False,",
          "    'enable_distributed_router': False,",
          "    'enable_firewall': False,",
          "    'enable_ha_router': False,",
          "    'enable_lb': False,",
          "    'enable_quotas': True,",
          "    'enable_security_group': True,",
          "    'enable_vpn': False,",
          'API_RESULT_LIMIT = 1000',
          'TIME_ZONE = "UTC"',
          'COMPRESS_OFFLINE = True',
          "FILE_UPLOAD_TEMP_DIR = '/tmp'"
        ])

        # From internals of verify_contents, get the contents to check for absence of a line
        content = catalogue.resource('concat::fragment', 'local_settings.py').send(:parameters)[:content]

        # With default options, should _not_ have a line to configure SESSION_ENGINE
        expect(content).not_to match(/^SESSION_ENGINE/)
      end

      it { is_expected.not_to contain_file('/tmp') }
    end

    context 'with overridden parameters' do
      before do
        params.merge!({
          :cache_backend                => 'horizon.backends.memcached.HorizonMemcached',
          :cache_options                => {'SOCKET_TIMEOUT' => 1,'SERVER_RETRIES' => 1,'DEAD_RETRY' => 1},
          :cache_server_ip              => '10.0.0.1',
          :django_session_engine        => 'django.contrib.sessions.backends.cache',
          :keystone_default_role        => 'SwiftOperator',
          :keystone_url                 => 'https://keystone.example.com:4682',
          :ssl_no_verify                => true,
          :log_handler                  => 'syslog',
          :log_level                    => 'DEBUG',
          :openstack_endpoint_type      => 'internalURL',
          :secondary_endpoint_type      => 'ANY-VALUE',
          :django_debug                 => true,
          :api_result_limit             => 4682,
          :compress_offline             => false,
          :hypervisor_options           => {'can_set_mount_point' => false, 'can_set_password' => true },
          :cinder_options               => {'enable_backup' => true },
          :keystone_options             => {'name' => 'native', 'can_edit_user' => true, 'can_edit_group' => true, 'can_edit_project' => true, 'can_edit_domain' => false, 'can_edit_role' => false},
          :neutron_options              => {'enable_lb' => true, 'enable_firewall' => true, 'enable_quotas' => false, 'enable_security_group' => false, 'enable_vpn' => true,
                                            'enable_distributed_router' => false, 'enable_ha_router' => false, 'profile_support' => 'cisco',
                                            'supported_provider_types' => ['flat', 'vxlan'], 'supported_vnic_types' => ['*'], 'default_ipv4_subnet_pool_label' => 'None', },
          :file_upload_temp_dir         => '/var/spool/horizon',
          :secure_cookies               => true,
          :api_versions                 => {'identity' => 2.0},
          :keystone_multidomain_support => true,
          :keystone_default_domain      => 'domain.tld',
          :overview_days_range          => 1,
          :session_timeout              => 1800,
          :timezone                     => 'Asia/Shanghai',
          :available_themes             => [
            { 'name' => 'default', 'label' => 'Default', 'path' => 'themes/default' },
            { 'name' => 'material', 'label' => 'Material', 'path' => 'themes/material' },
          ],
          :default_theme                => 'default',
          :password_autocomplete        => 'on',
          :images_panel                 => 'angular',
        })
      end

      it 'generates local_settings.py' do
        verify_concat_fragment_contents(catalogue, 'local_settings.py', [
          'DEBUG = True',
          "ALLOWED_HOSTS = ['*', ]",
          'CSRF_COOKIE_SECURE = True',
          'SESSION_COOKIE_SECURE = True',
          "  'identity': 2.0,",
          "OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True",
          "OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'domain.tld'",
          'HORIZON_CONFIG["password_autocomplete"] = "on"',
          'HORIZON_CONFIG["images_panel"] = "angular"',
          "SECRET_KEY = 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0'",
          "                'DEAD_RETRY': 1,",
          "                'SERVER_RETRIES': 1,",
          "                'SOCKET_TIMEOUT': 1,",
          "        'BACKEND': 'horizon.backends.memcached.HorizonMemcached',",
          "        'LOCATION': '10.0.0.1:11211',",
          'SESSION_ENGINE = "django.contrib.sessions.backends.cache"',
          'OPENSTACK_KEYSTONE_URL = "https://keystone.example.com:4682"',
          'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "SwiftOperator"',
          'OPENSTACK_SSL_NO_VERIFY = True',
          "OPENSTACK_KEYSTONE_BACKEND = {",
          "    'name': 'native',",
          "    'can_edit_user': True,",
          "    'can_edit_group': True,",
          "    'can_edit_project': True,",
          "    'can_edit_domain': False,",
          "    'can_edit_role': False,",
          "}",
          "    'can_set_mount_point': False,",
          "    'can_set_password': True,",
          "    'enable_backup': True,",
          "    'default_ipv4_subnet_pool_label': None,",
          "    'enable_firewall': True,",
          "    'enable_lb': True,",
          "    'enable_quotas': False,",
          "    'enable_security_group': False,",
          "    'enable_vpn': True,",
          "    'profile_support': 'cisco',",
          "    'supported_provider_types': ['flat', 'vxlan'],",
          "    'supported_vnic_types': ['*'],",
          'OPENSTACK_ENDPOINT_TYPE = "internalURL"',
          'SECONDARY_ENDPOINT_TYPE = "ANY-VALUE"',
          'API_RESULT_LIMIT = 4682',
          'TIME_ZONE = "Asia/Shanghai"',
          "AVAILABLE_THEMES = [",
          "  ('default', 'Default', 'themes/default'),",
          "  ('material', 'Material', 'themes/material'),",
          "]",
          "DEFAULT_THEME = 'default'",
          "            'level': 'DEBUG',",
          "            'handlers': ['syslog'],",
          "SESSION_TIMEOUT = 1800",
          'COMPRESS_OFFLINE = False',
          "FILE_UPLOAD_TEMP_DIR = '/var/spool/horizon'",
          "OVERVIEW_DAYS_RANGE = 1",
        ])
      end

      it { is_expected.not_to contain_file(platforms_params[:config_file]).that_notifies('Exec[refresh_horizon_django_cache]') }
      it { is_expected.not_to contain_file(platforms_params[:config_file]).that_notifies('Exec[refresh_horizon_django_compress]') }

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

      it { is_expected.to contain_exec('refresh_horizon_django_cache') }
      it { is_expected.to contain_exec('refresh_horizon_django_compress') }
    end

    context 'installs python memcache library when cache_backend is set to memcache' do
      before do
        params.merge!({
          :cache_backend => 'django.core.cache.backends.memcached.MemcachedCache'
        })
      end

      it {
        is_expected.to contain_package('python-memcache').with(
          :tag    => ['openstack']
         )
      }
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
          :listen_ssl   => true,
          :servername   => 'some.host.tld',
          :horizon_cert => '/etc/pki/tls/certs/httpd.crt',
          :horizon_key  => '/etc/pki/tls/private/httpd.key',
          :horizon_ca   => '/etc/pki/tls/certs/ca.crt',
        })
      end

      it 'configures apache' do
        is_expected.to contain_class('horizon::wsgi::apache').with({
          :bind_address => nil,
          :listen_ssl   => true,
          :horizon_cert => '/etc/pki/tls/certs/httpd.crt',
          :horizon_key  => '/etc/pki/tls/private/httpd.key',
          :horizon_ca   => '/etc/pki/tls/certs/ca.crt',
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
          "HORIZON_CONFIG = {",
          "    'dashboards': ('project', 'admin', 'settings',),",
          "    'default_dashboard': 'project',",
          "    'user_home': 'openstack_dashboard.views.get_user_home',",
          "    'ajax_queue_limit': 10,",
          "    'auto_fade_alerts': {",
          "        'delay': 3000,",
          "        'fade_duration': 1500,",
          "        'types': ['alert-success', 'alert-info']",
          "    },",
          "    'help_url': \"https://docs.openstack.org\",",
          "    'exceptions': {'recoverable': exceptions.RECOVERABLE,",
          "                   'not_found': exceptions.NOT_FOUND,",
          "                   'unauthorized': exceptions.UNAUTHORIZED},",
          "}",
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
  end

  shared_examples_for 'horizon on RedHat' do
    it 'sets WEBROOT in local_settings.py' do
      verify_concat_fragment_contents(catalogue, 'local_settings.py', [
        "WEBROOT = '/dashboard/'",
      ])
    end
  end

  shared_examples_for 'horizon on Debian' do
    it 'sets WEBROOT in local_settings.py' do
      verify_concat_fragment_contents(catalogue, 'local_settings.py', [
        "WEBROOT = '/horizon/'",
      ])
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :fqdn           => 'some.host.tld',
          :processorcount => 2,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      let(:platforms_params) do
        case facts[:osfamily]
        when 'Debian'
          { :config_file       => '/etc/openstack-dashboard/local_settings.py',
            :package_name      => 'openstack-dashboard',
            :root_url          => '/horizon' }
        when 'RedHat'
          { :config_file       => '/etc/openstack-dashboard/local_settings',
            :package_name      => 'openstack-dashboard',
            :root_url          => '/dashboard' }
        end
      end

      it_behaves_like 'horizon'
      it_behaves_like "horizon on #{facts[:osfamily]}"
    end
  end

end
