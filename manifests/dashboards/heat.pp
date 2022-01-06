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
# == Class: horizon::dashboards::heat
#
# Manage parameters of heat-dashboard
#
# === Parameters:
#
#  [*enable_user_pass*]
#    (optional) Enable the password field while launching a Heat stack.
#    Defaults to true
#
#  [*policy_file*]
#    (optional) Local copy of service policy files.
#    Defaults to 'heat_policy.yaml'
#
#  [*template_generator_api_timeout*]
#    (optional) API timeout to retrieve response from template generator.
#    Defaults to 60
#
#  [*template_generator_api_parallel*]
#    (optional) Concurrency to retrieve response from template generator.
#    Defualts to 2
#
#  [*policies*]
#    (optional) Set of policies to configure.
#    Defaults to undef
#
class horizon::dashboards::heat(
  $enable_user_pass                = true,
  $policy_file                     = 'heat_policy.yaml',
  $template_generator_api_timeout  = 60,
  $template_generator_api_parallel = 2,
  $policies                        = undef,
) {

  include horizon::deps
  include horizon::params

  # The horizon class should be included so that some common parameters
  # can be picked here.
  if ! defined(Class[horizon]) {
    fail('The horizon class should be included before the horizon::dashboards::heat class')
  }
  $log_handlers = $::horizon::log_handlers
  $log_level    = $::horizon::log_level
  $policy_files = $::horizon::policy_files

  if $policy_files and $policy_files['orchestration'] {
    $policy_file_real = $policy_files['orchestration']
  } else {
    $policy_file_real = $policy_file
  }

  $enable_user_pass_real = pick($::horizon::enable_user_pass, $enable_user_pass)

  $config_file = "${::horizon::params::conf_d_dir}/_1699_orchestration_settings.py"

  package { 'heat-dashboard':
    ensure => $::horizon::package_ensure,
    name   => $::horizon::params::heat_dashboard_package_name,
    tag    => ['openstack', 'horizon-package'],
  }

  concat { $config_file:
    mode    => '0640',
    owner   => $::horizon::params::wsgi_user,
    group   => $::horizon::params::wsgi_group,
    require => File[$::horizon::params::conf_d_dir],
    tag     => ['django-config'],
  }

  concat::fragment { '_1699_orchestration_settings.py':
    target  => $config_file,
    content => template('horizon/_1699_orchestration_settings.py.erb'),
    order   => '50',
  }

  if $policies != undef {
    # The horizon::policy class should be included so that some common
    # parameters about policy management can be picked here
    if !defined(Class[horizon::policy]){
      fail('The horizon::policy class should be include in advance to customize policies')
    }

    horizon::policy::base { $policy_file_real:
      policies     => $policies,
      file_mode    => $::horizon::policy::file_mode,
      file_format  => $::horizon::policy::file_format,
      purge_config => $::horizon::policy::purge_config,
    }
  }
}
