# these parameters need to be accessed from several locations and
# should be considered to be constant
class horizon::params {
  include openstacklib::defaults

  $logdir                 = '/var/log/horizon'
  $manage_py              = '/usr/share/openstack-dashboard/manage.py'
  $wsgi_application_group = '%{GLOBAL}'

  case $facts['os']['family'] {
    'RedHat': {
      $package_name                     = 'openstack-dashboard'
      $config_dir                       = '/etc/openstack-dashboard'
      $conf_d_dir                       = '/etc/openstack-dashboard/local_settings.d'
      $config_file                      = '/etc/openstack-dashboard/local_settings'
      $policy_dir                       = '/etc/openstack-dashboard'
      $httpd_config_file                = '/etc/httpd/conf.d/openstack-dashboard.conf'
      $httpd_listen_config_file         = '/etc/httpd/conf/httpd.conf'
      $root_url                         = '/dashboard'
      $static_path                      = '/usr/share'
      $django_wsgi                      = '/usr/share/openstack-dashboard/openstack_dashboard/wsgi.py'
      $wsgi_user                        = 'apache'
      $wsgi_group                       = 'apache'
      $memcache_package                 = 'python3-memcached'
      $pymemcache_package               = 'python3-pymemcache'
      $designate_dashboard_package_name = 'openstack-designate-ui'
      $heat_dashboard_package_name      = 'openstack-heat-ui'
      $ironic_dashboard_package_name    = 'openstack-ironic-ui'
      $manila_dashboard_package_name    = 'openstack-manila-ui'
      $octavia_dashboard_package_name   = 'openstack-octavia-ui'
    }
    'Debian': {
      $config_dir                       = '/etc/openstack-dashboard'
      $conf_d_dir                       = '/etc/openstack-dashboard/local_settings.d'
      $config_file                      = '/etc/openstack-dashboard/local_settings.py'
      $policy_dir                       = undef
      $httpd_listen_config_file         = '/etc/apache2/ports.conf'
      $root_url                         = '/horizon'
      $static_path                      = '/var/lib'
      $wsgi_user                        = 'horizon'
      $wsgi_group                       = 'horizon'
      $memcache_package                 = 'python3-memcache'
      $pymemcache_package               = 'python3-pymemcache'
      $designate_dashboard_package_name = 'python3-designate-dashboard'
      $heat_dashboard_package_name      = 'python3-heat-dashboard'
      $ironic_dashboard_package_name    = 'python3-ironic-ui'
      $manila_dashboard_package_name    = 'python3-manila-ui'
      $octavia_dashboard_package_name   = 'python3-octavia-dashboard'
      case $facts['os']['name'] {
        'Debian': {
          $package_name      = 'openstack-dashboard-apache'
          $httpd_config_file = '/etc/apache2/sites-available/openstack-dashboard-alias-only.conf'
          $django_wsgi       = '/usr/share/openstack-dashboard/wsgi.py'
        }
        default: {
          $package_name      = 'openstack-dashboard'
          $httpd_config_file = '/etc/apache2/conf-available/openstack-dashboard.conf'
          $django_wsgi       = '/usr/share/openstack-dashboard/openstack_dashboard/wsgi.py'
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }
}
