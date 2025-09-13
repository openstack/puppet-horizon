require 'spec_helper'

describe 'horizon::dashboards::cloudkitty' do

  let :params do
    {}
  end

  shared_examples_for 'horizon::dashboards::cloudkitty' do

    context 'with default parameters' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          }
eos
      end
      it 'installs cloudkitty-dashboard package' do
        is_expected.to contain_package('cloudkitty-dashboard').with(
          :ensure => 'present',
          :name   => platform_params[:cloudkitty_dashboard_package_name],
          :tag    => ['openstack', 'horizon-package']
        )
      end
    end

    context 'with parameters' do
      let(:pre_condition) do
        <<-eos
          class { 'horizon':
            secret_key => 'elj1IWiLoWHgcyYxFVLj7cM5rGOOxWl0',
          }
eos
      end
      before do
        params.merge!({
          :rate_prefix       => 'prefix',
          :rate_postfix      => 'postfix',
          :quotation_service => 'instance',
        })
      end
      it 'generates _3200_rating_settings.py' do
        verify_concat_fragment_contents(catalogue, '_3200_rating_settings.py', [
          "OPENSTACK_CLOUDKITTY_RATE_PREFIX = 'prefix'",
        ])
        verify_concat_fragment_contents(catalogue, '_3200_rating_settings.py', [
          "OPENSTACK_CLOUDKITTY_RATE_POSTFIX = 'postfix'",
        ])
        verify_concat_fragment_contents(catalogue, '_3200_rating_settings.py', [
          "CLOUDKITTY_QUOTATION_SERVICE = 'instance'",
        ])
      end
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
          { :cloudkitty_dashboard_package_name => 'python3-cloudkitty-dashboard' }
        when 'RedHat'
          { :cloudkitty_dashboard_package_name => 'openstack-cloudkitty-ui' }
        end
      end

      it_behaves_like 'horizon::dashboards::cloudkitty'
    end
  end

end
