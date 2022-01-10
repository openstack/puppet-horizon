require 'spec_helper'

describe 'horizon::policy' do

  let :params do
    {}
  end

  shared_examples_for 'horizon::policy' do

    context 'with default parameters' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key        => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
            policy_files_path => '/etc/openstack-dashboard'
          }
eos
      end

      it 'configures defaults' do
        is_expected.to contain_horizon__policy__base('cinder_policy.yaml').with(
          :file_mode    => '0640',
          :file_format  => 'yaml',
          :purge_config => false,
        )
        is_expected.to contain_horizon__policy__base('glance_policy.yaml').with(
          :file_mode    => '0640',
          :file_format  => 'yaml',
          :purge_config => false,
        )
        is_expected.to contain_horizon__policy__base('keystone_policy.yaml').with(
          :file_mode    => '0640',
          :file_format  => 'yaml',
          :purge_config => false,
        )
        is_expected.to contain_horizon__policy__base('neutron_policy.yaml').with(
          :file_mode    => '0640',
          :file_format  => 'yaml',
          :purge_config => false,
        )
        is_expected.to contain_horizon__policy__base('nova_policy.yaml').with(
          :file_mode    => '0640',
          :file_format  => 'yaml',
          :purge_config => false,
        )
      end
    end

    context 'with parameters' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key        => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
            policy_files_path => '/opt/openstack-dashboard',
            policy_files      => {
              'identity' => 'keystone.yaml',
              'compute'  => 'nova.yaml',
              'volume'   => 'cinder.yaml',
              'image'    => 'glance.yaml',
              'network'  => 'neutron.yaml'
            }
          }
eos
      end

      let :params do
        {
          :file_mode    => '0644',
          :purge_config => true,
        }
      end

      it 'configures defaults' do
        is_expected.to contain_horizon__policy__base('cinder.yaml').with(
          :file_mode    => '0644',
          :file_format  => 'yaml',
          :purge_config => true,
        )
        is_expected.to contain_horizon__policy__base('glance.yaml').with(
          :file_mode    => '0644',
          :file_format  => 'yaml',
          :purge_config => true,
        )
        is_expected.to contain_horizon__policy__base('keystone.yaml').with(
          :file_mode    => '0644',
          :file_format  => 'yaml',
          :purge_config => true,
        )
        is_expected.to contain_horizon__policy__base('neutron.yaml').with(
          :file_mode    => '0644',
          :file_format  => 'yaml',
          :purge_config => true,
        )
        is_expected.to contain_horizon__policy__base('nova.yaml').with(
          :file_mode    => '0644',
          :file_format  => 'yaml',
          :purge_config => true,
        )
      end
    end

    context 'without the horizon class defined' do
      it { should raise_error(Puppet::Error) }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'horizon::policy'
    end
  end

end
