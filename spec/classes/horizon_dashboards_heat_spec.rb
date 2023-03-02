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
        verify_concat_fragment_contents(catalogue, '_1699_orchestration_settings.py', [
          "HEAT_TEMPLATE_GENERATOR_API_TIMEOUT = 60"
        ])
        verify_concat_fragment_contents(catalogue, '_1699_orchestration_settings.py', [
          "HEAT_TEMPLATE_GENERATOR_API_PARALLEL = 2"
        ])
      end
    end

    context 'with enable_user_pass disabled' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          }
eos
      end
      before do
        params.merge!({ :enable_user_pass => false })
      end
      it 'generates _1699_orchestration_settings.py' do
        verify_concat_fragment_contents(catalogue, '_1699_orchestration_settings.py', [
          "OPENSTACK_HEAT_STACK = {",
          "    'enable_user_pass': False,",
          "}",
        ])
      end
    end

    context 'with template_generator parameters set' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          }
eos
      end
      before do
        params.merge!({
          :template_generator_api_timeout  => 120,
          :template_generator_api_parallel => 4,
        })
      end
      it 'generates _1699_orchestration_settings.py' do
        verify_concat_fragment_contents(catalogue, '_1699_orchestration_settings.py', [
          "HEAT_TEMPLATE_GENERATOR_API_TIMEOUT = 120"
        ])
        verify_concat_fragment_contents(catalogue, '_1699_orchestration_settings.py', [
          "HEAT_TEMPLATE_GENERATOR_API_PARALLEL = 4"
        ])
      end
    end

    context 'without the horizon class defined' do
      it { should raise_error(Puppet::Error) }
    end

    context 'with policy customization' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key        => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
            policy_files_path => '/etc/openstack-dashboard',
          }
          class { 'horizon::policy': }
eos
      end

      before do
        params.merge!({
          :policies => {}
        })
      end

      it 'configures policy' do
        is_expected.to contain_horizon__policy__base('heat_policy.yaml').with(
          :policies     => {},
          :file_mode    => '0640',
          :file_format  => 'yaml',
          :purge_config => false,
        )
      end
    end

    context 'with policy customization but without the horizon::policy class' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key        => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
            policy_files_path => '/etc/openstack-dashboard',
          }
eos
      end

      before do
        params.merge!({
          :policies => {}
        })
      end

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
          { :heat_dashboard_package_name => 'python3-heat-dashboard' }
        when 'RedHat'
          { :heat_dashboard_package_name => 'openstack-heat-ui' }
        end
      end

      it_behaves_like 'horizon::dashboards::heat'
    end
  end

end
