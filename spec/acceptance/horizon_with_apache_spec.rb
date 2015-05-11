require 'spec_helper_acceptance'

describe 'horizon class' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      Exec { logoutput => 'on_failure' }

      include ::apt
      # some packages are not autoupgraded in trusty.
      # it will be fixed in liberty, but broken in kilo.
      $need_to_be_upgraded = ['python-tz', 'python-pbr']
      apt::source { 'trusty-updates-kilo':
        location          => 'http://ubuntu-cloud.archive.canonical.com/ubuntu/',
        release           => 'trusty-updates',
        repos             => 'kilo/main',
        required_packages => 'ubuntu-cloud-keyring',
        trusted_source    => true,
      } ~>
      exec { '/usr/bin/apt-get -y dist-upgrade': refreshonly => true, }
      Apt::Source['trusty-updates-kilo'] -> Package<| |>

      class { '::horizon':
        secret_key       => 'big_secret',
        # need to disable offline compression due to
        # https://bugs.launchpad.net/ubuntu/+source/horizon/+bug/1424042
        compress_offline => false,
        allowed_hosts    => 'localhost',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    # basic test for now, to make sure Apache serve /horizon dashboard
    describe command('curl --connect-timeout 5 -sL -w "%{http_code} %{url_effective}\n" http://localhost/horizon/ -o /dev/null') do
      it { should return_exit_status 0 }
    end

  end

end
