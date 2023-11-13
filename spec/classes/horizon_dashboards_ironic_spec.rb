require 'spec_helper'

describe 'horizon::dashboards::ironic' do

  let :params do
    {}
  end

  shared_examples_for 'horizon::dashboards::ironic' do

    context 'with default parameters' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          }
eos
      end

      it 'installs ironic-dashboard package' do
        is_expected.to contain_package('ironic-dashboard').with(
          :ensure => 'present',
          :name   => platform_params[:ironic_dashboard_package_name],
          :tag    => ['openstack', 'horizon-package']
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

      let(:platform_params) do
        case facts[:os]['family']
        when 'Debian'
          { :ironic_dashboard_package_name => 'python3-ironic-ui' }
        when 'RedHat'
          { :ironic_dashboard_package_name => 'openstack-ironic-ui' }
        end
      end

      it_behaves_like 'horizon::dashboards::ironic'
    end
  end

end
