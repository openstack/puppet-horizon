require 'spec_helper'

describe 'horizon::dashboards::heat' do

  let :params do
    {}
  end

  shared_examples_for 'horizon::dashboards::heat' do

    context 'with default parameters' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          }
eos
      end

      it 'installs heat-dashboard package' do
        is_expected.to contain_package('heat-dashboard').with(
          :ensure => 'present',
          :name   => platform_params[:heat_dashboard_package_name],
          :tag    => ['openstack', 'horizon-package']
        )
      end

      it 'generates _1699_orchestration_settings.py' do
        verify_concat_fragment_contents(catalogue, '_1699_orchestration_settings.py', [
          "settings.POLICY_FILES.update({",
          "    'orchestration': 'heat_policy.yaml',",
          "})"
        ])
        verify_concat_fragment_contents(catalogue, '_1699_orchestration_settings.py', [
          "OPENSTACK_HEAT_STACK = {",
          "    'enable_user_pass': True,",
          "}",
        ])
      end
    end

    context 'with enable_user_pass disabled' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            enable_user_pass => false,
            secret_key       => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          }
eos
      end

      before do
        # NOTE(tkajinam): We should test the enable_user_pass parameter in this
        #                 class but setting undef in the base horizon class
        #                 doesn't work for some reason...
        params.merge!({ :enable_user_pass => false })
      end

      it {
        verify_concat_fragment_contents(catalogue, '_1699_orchestration_settings.py', [
          "OPENSTACK_HEAT_STACK = {",
          "    'enable_user_pass': False,",
          "}",
        ])
      }
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
          { :heat_dashboard_package_name => 'python3-heat-dashboard' }
        when 'RedHat'
          { :heat_dashboard_package_name => 'openstack-heat-ui' }
        end
      end

      it_behaves_like 'horizon::dashboards::heat'
    end
  end

end
