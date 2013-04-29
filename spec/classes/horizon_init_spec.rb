require 'spec_helper'

describe 'horizon' do
  let :params do
    {
      'cache_server_ip' => '10.0.0.1',
      'secret_key'      => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0'
    }
  end

  let :pre_condition do
    'include apache'
  end

  let :facts do
    { :concat_basedir => '/var/lib/puppet/concat' }
  end

  describe 'on RedHat platforms' do
    before do
      facts.merge!({
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.0'
      })
    end

    it { should contain_service('httpd').with_name('httpd') }
    it { should contain_file('/etc/httpd/conf.d/openstack-dashboard.conf') }
  end

  describe 'on Debian platforms' do
    before do
      facts.merge!({
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6.0'
      })
    end

    it { should contain_service('httpd').with_name('apache2') }
    it { should_not contain_file('/etc/httpd/conf.d/openstack-dashboard.conf') }

    describe 'with default parameters' do
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^SECRET_KEY = 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0'$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^OPENSTACK_HOST = "127.0.0.1"$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^OPENSTACK_KEYSTONE_URL = "http:\/\/%s:5000\/v2.0" % OPENSTACK_HOST$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^OPENSTACK_KEYSTONE_DEFAULT_ROLE = "Member"$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^DEBUG = False$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^API_RESULT_LIMIT = 1000$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^\s*'can_set_mount_point': True$/) }
      it { should contain_package('horizon').with_ensure('present') }
    end

    describe 'when overriding parameters' do
      let :params do
        {
          :secret_key            => 'dummy',
          :cache_server_ip       => '10.0.0.1',
          :keystone_host         => 'keystone.example.com',
          :keystone_port         => 4682,
          :keystone_scheme       => 'https',
          :keystone_default_role => 'SwiftOperator',
          :django_debug          => 'True',
          :api_result_limit      => 4682,
          :can_set_mount_point      => 'False',
        }
      end

      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^SECRET_KEY = 'dummy'$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^OPENSTACK_HOST = "keystone.example.com"$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^OPENSTACK_KEYSTONE_URL = "https:\/\/%s:4682\/v2.0" % OPENSTACK_HOST$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^OPENSTACK_KEYSTONE_DEFAULT_ROLE = "SwiftOperator"$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^DEBUG = True$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^API_RESULT_LIMIT = 4682$/) }
      it { should contain_file('/etc/openstack-dashboard/local_settings.py').with_content(/^\s*'can_set_mount_point': False$/) }
    end
  end
end
