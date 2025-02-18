require 'spec_helper_acceptance'

describe 'horizon class' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::memcached

      include openstack_integration::horizon
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    # basic test for now, to make sure Apache serve /horizon dashboard
    if os[:family] == 'Debian'
      it 'executes curl and returns 200' do
        command('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://127.0.0.1/horizon -o /dev/null', :acceptable_exit_codes => [0]) do |r|
          expect(r.stdout).to match(/^200/)
        end
      end
    elsif os[:family] == 'RedHat'
      it 'executes curl and returns 200' do
        command('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://127.0.0.1/dashboard -o /dev/null', :acceptable_exit_codes => [0]) do |r|
          expect(r.stdout).to match(/^200/)
        end
      end
    end

  end

  context 'parameters with modified root' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::memcached

      class { 'openstack_integration::horizon':
        root_url => '',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    # basic test for now, to make sure Apache serve /horizon dashboard
    it 'executes curl and returns 200' do
      command('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://127.0.0.1 -o /dev/null', :acceptable_exit_codes => [0]) do |r|
        expect(r.stdout).to match(/^200/)
      end
    end
  end
end
