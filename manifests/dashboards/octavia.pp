#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: horizon::dashboards::octavia
#
# Manage parameters of octavia-dashboard
#
# === Parameters:
#
#  [*policy_file*]
#    (optional) Local copy of service policy files.
#    Defaults to 'octavia_policy.json'
#
class horizon::dashboards::octavia(
  $policy_file = 'octavia_policy.json',
) {

  include horizon::deps
  include horizon::params

  # The horizon class should be included so that some common parameters
  # can be picked here.
  if ! defined(Class[horizon]) {
    fail('The horizon class should be included before the horizon::dashboards::octavia class')
  }

  $log_handlers = $::horizon::log_handlers
  $log_level    = $::horizon::log_level
  $policy_files = $::horizon::policy_files

  if $policy_files and $policy_files['load-balancer'] {
    $policy_file_real = $policy_files['load-balancer']
  } else {
    $policy_file_real = $policy_file
  }

  $config_file = "${::horizon::params::conf_d_dir}/_1499_load_balancer_settings.py"

  package { 'octavia-dashboard':
    ensure => $::horizon::package_ensure,
    name   => $::horizon::params::octavia_dashboard_package_name,
    tag    => ['openstack', 'horizon-package'],
  }

  concat { $config_file:
    mode    => '0640',
    owner   => $::horizon::params::wsgi_user,
    group   => $::horizon::params::wsgi_group,
    require => File[$::horizon::params::conf_d_dir],
    tag     => ['django-config'],
  }

  concat::fragment { '_1499_load_balancer_settings.py':
    target  => $config_file,
    content => template('horizon/_1499_load_balancer_settings.py.erb'),
    order   => '50',
  }
}
