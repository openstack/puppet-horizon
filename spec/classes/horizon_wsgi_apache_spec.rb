require 'spec_helper'

describe 'horizon::wsgi::apache' do
  let :params do
    {
      :servername => 'some.host.tld',
    }
  end

  let :pre_condition do
    "include apache
    class { 'horizon': secret_key => 's3cr3t', configure_apache => false }"
  end

  let :fixtures_path do
    File.expand_path(File.join(__FILE__, '..', '..', 'fixtures'))
  end

  shared_examples 'horizon::wsgi::apache' do

    context 'with default parameters' do
      it { should contain_class('horizon::params') }
      it { should contain_class('apache') }
      it { should contain_class('apache::mod::wsgi') }
      it { should contain_file(platforms_params[:httpd_config_file]) }
      it { should contain_package('horizon').with_ensure('present') }

      it { should contain_apache__vhost('horizon_vhost').with(
        :servername                  => 'some.host.tld',
        :access_log_file             => 'horizon_access.log',
        :error_log_file              => 'horizon_error.log',
        :priority                    => 15,
        :serveraliases               => ['some.host.tld'],
        :docroot                     => '/var/www/',
        :ssl                         => 'false',
        :port                        => '80',
        :redirectmatch_status        => 'permanent',
        :redirectmatch_regexp        => '^/$',
        :redirectmatch_dest          => platforms_params[:root_url],
        :wsgi_script_aliases         => { platforms_params[:root_url] => '/usr/share/openstack-dashboard/openstack_dashboard/wsgi.py' },
        :wsgi_process_group          => platforms_params[:wsgi_group],
        :wsgi_daemon_process         => {
          platforms_params[:wsgi_group] => {
            'processes'    => facts[:os_workers],
            'threads'      => '1',
            'user'         => platforms_params[:wsgi_user],
            'group'        => platforms_params[:wsgi_group],
            'display-name' => 'horizon'
          }},
        :wsgi_application_group      => '%{GLOBAL}',
      )}
    end

    context 'with overridden parameters' do
      before do
        params.merge!({
          :priority          => 10,
          :redirect_type     => 'temp',
          :wsgi_processes    => '13',
          :wsgi_threads      => '3',
          :access_log_format => 'common',
        })
      end

      it { should contain_class('horizon::params') }
      it { should contain_class('apache') }
      it { should contain_class('apache::mod::wsgi') }
      it { should contain_file(platforms_params[:httpd_config_file]) }
      it { should contain_package('horizon').with_ensure('present') }

      it { should contain_apache__vhost('horizon_vhost').with(
        :servername                  => 'some.host.tld',
        :access_log_file             => 'horizon_access.log',
        :access_log_format           => 'common',
        :error_log_file              => 'horizon_error.log',
        :priority                    => params[:priority],
        :serveraliases               => ['some.host.tld'],
        :docroot                     => '/var/www/',
        :ssl                         => 'false',
        :port                        => '80',
        :redirectmatch_status        => 'temp',
        :redirectmatch_regexp        => '^/$',
        :redirectmatch_dest          => platforms_params[:root_url],
        :wsgi_script_aliases         => { platforms_params[:root_url] => '/usr/share/openstack-dashboard/openstack_dashboard/wsgi.py' },
        :wsgi_process_group          => platforms_params[:wsgi_group],
        :wsgi_daemon_process         => {
          platforms_params[:wsgi_group] => {
            'processes'    => '13',
            'threads'      => '3',
            'user'         => platforms_params[:wsgi_user],
            'group'        => platforms_params[:wsgi_group],
            'display-name' => 'horizon'
          }},
        :wsgi_application_group      => '%{GLOBAL}',
      )}
    end

    context 'with custom_custom_wsgi_options' do
      before do
        params.merge!({
          :custom_wsgi_process_options => {
            'user'        => 'myuser',
            'python_path' => '/my/python/admin/path',
          },
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :wsgi_daemon_process         => {
          platforms_params[:wsgi_group] => {
            'processes'    => facts[:os_workers],
            'threads'      => '1',
            'user'         => 'myuser',
            'group'        => platforms_params[:wsgi_group],
            'display-name' => 'horizon',
            'python_path'  => '/my/python/admin/path'
          }}
      )}
    end

    context 'with ssl enabled' do
      before do
        params.merge!({
          :listen_ssl        => true,
          :ssl_redirect      => true,
          :ssl_cert          => '/etc/pki/tls/certs/httpd.crt',
          :ssl_key           => '/etc/pki/tls/private/httpd.key',
          :ssl_ca            => '/etc/pki/tls/certs/ca.crt',
          :ssl_verify_client => 'optional',
        })
      end

      it { should contain_class('apache::mod::ssl') }

      it { should contain_apache__vhost('horizon_ssl_vhost').with(
        :servername             => 'some.host.tld',
        :access_log_file        => 'horizon_ssl_access.log',
        :error_log_file         => 'horizon_ssl_error.log',
        :priority               => 15,
        :serveraliases          => ['some.host.tld'],
        :docroot                => '/var/www/',
        :ssl                    => 'true',
        :port                   => '443',
        :ssl_cert               => '/etc/pki/tls/certs/httpd.crt',
        :ssl_key                => '/etc/pki/tls/private/httpd.key',
        :ssl_ca                 => '/etc/pki/tls/certs/ca.crt',
        :ssl_verify_client      => 'optional',
        :redirectmatch_status   => 'permanent',
        :redirectmatch_regexp   => '^/$',
        :redirectmatch_dest     => platforms_params[:root_url],
        :wsgi_process_group     => 'horizon-ssl',
        :wsgi_daemon_process    => {
          'horizon-ssl' => {
            'processes'    => facts[:os_workers],
            'threads'      => '1',
            'user'         => platforms_params[:wsgi_user],
            'group'        => platforms_params[:wsgi_group],
            'display-name' => 'horizon'
          }},
        :wsgi_application_group => '%{GLOBAL}',
        :wsgi_script_aliases    => {
          platforms_params[:root_url] => '/usr/share/openstack-dashboard/openstack_dashboard/wsgi.py'
        }
      )}

      it { should contain_apache__vhost('horizon_vhost').with(
        :servername             => 'some.host.tld',
        :access_log_file        => 'horizon_access.log',
        :error_log_file         => 'horizon_error.log',
        :priority               => 15,
        :serveraliases          => ['some.host.tld'],
        :docroot                => '/var/www/',
        :ssl                    => 'false',
        :port                   => '80',
        :redirectmatch_status   => 'permanent',
        :redirectmatch_regexp   => '(.*)',
        :redirectmatch_dest     => 'https://some.host.tld',
        :wsgi_process_group     => platforms_params[:wsgi_group],
        :wsgi_daemon_process    => {
          platforms_params[:wsgi_group] => {
            'processes'    => facts[:os_workers],
            'threads'      => '1',
            'user'         => platforms_params[:wsgi_user],
            'group'        => platforms_params[:wsgi_group],
            'display-name' => 'horizon'
          }},
        :wsgi_application_group => '%{GLOBAL}',
        :wsgi_script_aliases    => {
          platforms_params[:root_url] => '/usr/share/openstack-dashboard/openstack_dashboard/wsgi.py'
        }
      )}
    end

    context 'without ssl_cert parameter' do
      before do
        params.merge!( :listen_ssl => true )
      end

      it { should raise_error(Puppet::Error, /The ssl_cert parameter is required when listen_ssl is true/) }
    end

    context 'without ssl_key parameter' do
      before do
        params.merge!( :listen_ssl => true,
                       :ssl_cert   => '/etc/pki/tls/certs/httpd.crt' )
      end

      it { should raise_error(Puppet::Error, /The ssl_key parameter is required when listen_ssl is true/) }
    end

    context 'without ssl_verify_client' do
      before do
        params.merge!( :listen_ssl => true,
                       :ssl_cert   => '/etc/pki/tls/certs/httpd.crt',
                       :ssl_key    => '/etc/pki/tls/certs/httpd.key',
                       :ssl_ca     => '/etc/pki/tls/certs/httpd.ca' )
      end

      it { should raise_error(Puppet::Error, /The ssl_verify_client parameter is required when setting ssl_ca/) }
    end

    context 'with extra parameters' do
      before do
        params.merge!({
          :extra_params  => {
            'add_listen' => false,
            'docroot'    => '/tmp'
          },
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :add_listen => false,
        :docroot    => '/tmp'
      )}
      it { should contain_apache__vhost('horizon_ssl_vhost').with(
        :add_listen => false,
        :docroot    => '/tmp'
      )}
    end

    context 'with ssl extra parameters' do
      before do
        params.merge!({
          :extra_params  => {
            'docroot' => '/root1'
          },
          :ssl_extra_params  => {
            'docroot' => '/root2'
          },
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :docroot => '/root1'
      )}
      it { should contain_apache__vhost('horizon_ssl_vhost').with(
        :docroot => '/root2'
      )}
    end

    context 'with root_url set to /' do
      before do
        params.merge!({
          :root_url  => '/',
          :root_path => '/tmp/horizon'
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :aliases             => [
          { 'alias' => '/static', 'path' => '/tmp/horizon/static' }
        ],
        :wsgi_script_aliases => {
          '/' => '/usr/share/openstack-dashboard/openstack_dashboard/wsgi.py'
        }
      )}

      it { should_not contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => '/'
      )}

      it { should_not contain_apache__vhost('horizon_ssl_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => '/'
      )}
    end

    context 'with root_url set to empty' do
      before do
        params.merge!({
          :root_url => '',
        })
      end

      it { should_not contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => '(.*)',
        :redirectmatch_dest   => '/'
      )}

      it { should_not contain_apache__vhost('horizon_ssl_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => ''
      )}
    end

    context 'without ssl and custom root_url' do
      before do
        params.merge!({
          :listen_ssl => false,
          :root_url   => '/custom',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => '/custom',
      )}
    end

    context 'without ssl and slash root_url' do
      before do
        params.merge!({
          :listen_ssl => false,
          :root_url   => '/',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => nil,
        :redirectmatch_dest   => nil,
      )}
    end

    context 'with listen_ssl and ssl_redirect set to true' do
      before do
        params.merge!({
          :listen_ssl        => true,
          :ssl_redirect      => true,
          :ssl_cert          => '/etc/pki/tls/certs/httpd.crt',
          :ssl_key           => '/etc/pki/tls/private/httpd.key',
          :ssl_ca            => '/etc/pki/tls/certs/ca.crt',
          :ssl_verify_client => 'optional',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => '(.*)',
        :redirectmatch_dest   => 'https://some.host.tld',
      )}

      it { should contain_apache__vhost('horizon_ssl_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => platforms_params[:root_url],
      )}
    end

    context 'with listen_ssl and ssl_redirect with a slash root_url' do
      before do
        params.merge!({
          :listen_ssl        => true,
          :ssl_redirect      => true,
          :ssl_cert          => '/etc/pki/tls/certs/httpd.crt',
          :ssl_key           => '/etc/pki/tls/private/httpd.key',
          :ssl_ca            => '/etc/pki/tls/certs/ca.crt',
          :ssl_verify_client => 'optional',
          :root_url          => '/',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => '(.*)',
        :redirectmatch_dest   => 'https://some.host.tld',
      )}

      it { should contain_apache__vhost('horizon_ssl_vhost').with(
        :redirectmatch_regexp => nil,
        :redirectmatch_dest   => nil,
      )}
    end

    context 'with listen_ssl and ssl_redirect with an empty root_url' do
      before do
        params.merge!({
          :listen_ssl        => true,
          :ssl_redirect      => true,
          :ssl_cert          => '/etc/pki/tls/certs/httpd.crt',
          :ssl_key           => '/etc/pki/tls/private/httpd.key',
          :ssl_ca            => '/etc/pki/tls/certs/ca.crt',
          :ssl_verify_client => 'optional',
          :root_url          => '',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => '(.*)',
        :redirectmatch_dest   => 'https://some.host.tld',
      )}

      it { should contain_apache__vhost('horizon_ssl_vhost').with(
        :redirectmatch_regexp => nil,
        :redirectmatch_dest   => nil,
      )}
    end

    context 'with listen_ssl and ssl_redirect disabled' do
      before do
        params.merge!({
          :listen_ssl        => true,
          :ssl_redirect      => false,
          :ssl_cert          => '/etc/pki/tls/certs/httpd.crt',
          :ssl_key           => '/etc/pki/tls/private/httpd.key',
          :ssl_ca            => '/etc/pki/tls/certs/ca.crt',
          :ssl_verify_client => 'optional',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => platforms_params[:root_url],
      )}

      it { should contain_apache__vhost('horizon_ssl_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => platforms_params[:root_url],
      )}
    end

    context 'with listen_ssl and ssl_redirect disabled with custom root_url' do
      before do
        params.merge!({
          :listen_ssl        => true,
          :ssl_redirect      => false,
          :ssl_cert          => '/etc/pki/tls/certs/httpd.crt',
          :ssl_key           => '/etc/pki/tls/private/httpd.key',
          :ssl_ca            => '/etc/pki/tls/certs/ca.crt',
          :ssl_verify_client => 'optional',
          :root_url          => '/custom',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => '/custom',
      )}

      it { should contain_apache__vhost('horizon_ssl_vhost').with(
        :redirectmatch_regexp => '^/$',
        :redirectmatch_dest   => '/custom',
      )}
    end
  end

  shared_examples 'horizon::wsgi::apache on RedHat' do
    it { should contain_apache__vhost('horizon_vhost').with(
      :aliases => [
        { 'alias' => '/dashboard/static', 'path' => '/usr/share/openstack-dashboard/static' }
      ],
    )}

    context 'with root_path set to /tmp/horizon' do
      before do
        params.merge!({
          :root_path => '/tmp/horizon',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :aliases => [
          { 'alias' => '/dashboard/static', 'path' => '/tmp/horizon/static' }
        ],
      )}
    end
  end

  shared_examples 'horizon::wsgi::apache on Debian' do
    it { should contain_apache__vhost('horizon_vhost').with(
      :aliases => [
        { 'alias' => '/horizon/static', 'path' => '/var/lib/openstack-dashboard/static' }
      ],
    )}

    context 'with root_path set to /tmp/horizon' do
      before do
        params.merge!({
          :root_path => '/tmp/horizon',
        })
      end

      it { should contain_apache__vhost('horizon_vhost').with(
        :aliases => [
          { 'alias' => '/horizon/static', 'path' => '/tmp/horizon/static' }
        ],
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :fqdn           => 'some.host.tld',
          :concat_basedir => '/var/lib/puppet/concat',
          :os_workers     => '6'
        }))
      end

      let(:platforms_params) do
        case facts[:osfamily]
        when 'Debian'
          case facts[:operatingsystem]
          when 'Debian'
            { :httpd_config_file => '/etc/apache2/sites-available/openstack-dashboard-alias-only.conf',
              :root_url          => '/horizon',
              :wsgi_user         => 'horizon',
              :wsgi_group        => 'horizon' }
          when 'Ubuntu'
            { :httpd_config_file => '/etc/apache2/conf-available/openstack-dashboard.conf',
              :root_url          => '/horizon',
              :wsgi_user         => 'horizon',
              :wsgi_group        => 'horizon' }
          end
        when 'RedHat'
          { :httpd_config_file => '/etc/httpd/conf.d/openstack-dashboard.conf',
            :root_url          => '/dashboard',
            :wsgi_user         => 'apache',
            :wsgi_group        => 'apache' }
        end
      end

      it_behaves_like 'horizon::wsgi::apache'
      it_behaves_like "horizon::wsgi::apache on #{facts[:osfamily]}"
    end
  end

end
