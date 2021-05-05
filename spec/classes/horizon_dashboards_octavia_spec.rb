require 'spec_helper'

describe 'horizon::dashboards::octavia' do

  let :params do
    {}
  end

  shared_examples_for 'horizon::dashboards::octavia' do

    context 'with default parameters' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          }
eos
      end

      it 'installs octavia-dashboard package' do
        is_expected.to contain_package('octavia-dashboard').with(
          :ensure => 'present',
          :name   => platform_params[:octavia_dashboard_package_name],
          :tag    => ['openstack', 'horizon-package']
        )
      end

      it 'generates _1499_load_balancer_settings.py' do
        verify_concat_fragment_contents(catalogue, '_1499_load_balancer_settings.py', [
          "settings.POLICY_FILES.update({",
          "    'load-balancer': 'octavia_policy.yaml',",
          "})"
        ])
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
        case facts[:osfamily]
        when 'Debian'
          { :octavia_dashboard_package_name => 'python3-octavia-dashboard' }
        when 'RedHat'
          { :octavia_dashboard_package_name => 'openstack-octavia-ui' }
        end
      end

      it_behaves_like 'horizon::dashboards::octavia'
    end
  end

end
