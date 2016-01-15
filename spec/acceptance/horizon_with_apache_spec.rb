require 'spec_helper_acceptance'

describe 'horizon class' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos

      class { '::horizon':
        secret_key       => 'big_secret',
        # need to disable offline compression due to
        # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
        compress_offline => false,
        allowed_hosts    => [$::fqdn, 'localhost'],
        server_aliases   => [$::fqdn, 'localhost'],
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    # basic test for now, to make sure Apache serve /horizon dashboard
    if os[:family] == 'Debian'
      it 'executes curl and returns 200' do
        shell('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://localhost/horizon -o /dev/null', :acceptable_exit_codes => [0]) do |r|
          expect(r.stdout).to match(/^200/)
        end
      end
    elsif os[:family] == 'RedHat'
      it 'executes curl and returns 200' do
        shell('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://localhost/dashboard -o /dev/null', :acceptable_exit_codes => [0]) do |r|
          expect(r.stdout).to match(/^200/)
        end
      end
    end

  end

  context 'parameters with modified root' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos

      class { '::horizon':
        secret_key       => 'big_secret',
        # need to disable offline compression due to
        # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
        compress_offline => false,
        allowed_hosts    => [$::fqdn, 'localhost'],
        server_aliases   => [$::fqdn, 'localhost'],
        root_url         => '',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    # basic test for now, to make sure Apache serve /horizon dashboard
    it 'executes curl and returns 200' do
      shell('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://localhost -o /dev/null', :acceptable_exit_codes => [0]) do |r|
        expect(r.stdout).to match(/^200/)
      end
    end
  end
end
