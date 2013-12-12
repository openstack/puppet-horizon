# these parameters need to be accessed from several locations and
# should be considered to be constant
class horizon::params {

  $logdir = '/var/log/horizon'

  case $::osfamily {
    'RedHat': {
      $http_service                = 'httpd'
      $http_modwsgi                = 'mod_wsgi'
      $package_name                = 'openstack-dashboard'
      $config_file                 = '/etc/openstack-dashboard/local_settings'
      $root_url                    = '/dashboard'
      $apache_user                 = 'apache'
      $apache_group                = 'apache'
    }
    'Debian': {
      $http_service                = 'apache2'
      $config_file                 = '/etc/openstack-dashboard/local_settings.py'
      $root_url                    = '/horizon'
      $apache_user                 = 'horizon'
      $apache_group                = 'horizon'
      case $::operatingsystem {
        'Debian': {
            $package_name          = 'openstack-dashboard-apache'
        }
        default: {
            $package_name          = 'openstack-dashboard'
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }
}
