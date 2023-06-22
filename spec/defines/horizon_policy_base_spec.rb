require 'spec_helper'

describe 'horizon::policy::base' do
  let (:title) { 'keystone_policy.yaml' }

  shared_examples 'horizon::policy::base' do
    context 'with default' do
      let :pre_condition do
        <<-eos
        class { 'horizon':
          secret_key        => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          policy_files_path => '/etc/openstack-dashboard'
        }
eos
      end

      let :params do
        {}
      end

      it 'should configure defaults' do
        is_expected.to contain_openstacklib__policy('/etc/openstack-dashboard/keystone_policy.yaml').with(
          :policies     => {},
          :file_user    => platform_params[:wsgi_user],
          :file_group   => platform_params[:wsgi_group],
          :file_mode    => '0640',
          :purge_config => false,
          :tag          => 'horizon',
        )
      end
    end

    context 'with parameters' do
      let :pre_condition do
        <<-eos
        class { 'horizon':
          secret_key        => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          policy_files_path => '/opt/openstack-dashboard'
        }
eos
      end

      let :params do
        {
          :file_mode    => '0644',
          :purge_config => true,
        }
      end

      it 'should configure defaults' do
        is_expected.to contain_openstacklib__policy('/opt/openstack-dashboard/keystone_policy.yaml').with(
          :policies     => {},
          :file_user    => platform_params[:wsgi_user],
          :file_group   => platform_params[:wsgi_group],
          :file_mode    => '0644',
          :purge_config => true,
          :tag          => 'horizon',
        )
      end
    end

    context 'without the horizon class defined' do
      it { should raise_error(Puppet::Error) }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let (:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :wsgi_user  => 'horizon',
            :wsgi_group => 'horizon' }
        when 'RedHat'
          { :wsgi_user  => 'apache',
            :wsgi_group => 'apache' }
        end
      end

      it_behaves_like 'horizon::policy::base'
    end
  end

end
