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
# == Class: horizon::dashboards::manila
#
# Manage parameters of manila-dashboard
#
# === Parameters:
#
#  [*policy_file*]
#    (optional) Local copy of service policy files.
#    Defaults to 'manila_policy.json'
#
#  [*manila_options*]
#    (optional) A hash of parameters to enable features specific to Manila.
#    These include;
#    'enable_share_groups': Boolean
#    'enable_replication': Boolean
#    'enable_migration': Boolean
#    'enable_public_share_type_creation': Boolean
#    'enable_public_share_group_type_creation': Boolean
#    'enable_public_shares': Boolean
#    'enabled_share_protocols': Array
#
class horizon::dashboards::manila(
  $policy_file    = 'manila_policy.json',
  $manila_options = {}
) {

  include horizon::deps
  include horizon::params

  # The horizon class should be included so that some common parameters
  # can be picked here.
  if ! defined(Class[horizon]) {
    fail('The horizon class should be included before the horizon::dashboards::manila class')
  }
  $log_handlers = $::horizon::log_handlers_real
  $log_level    = $::horizon::log_level
  $policy_files = $::horizon::policy_files

  if $policy_files and $policy_files['share'] {
    $policy_file_real = $policy_files['share']
  } else {
    $policy_file_real = $policy_file
  }

  # Default options for the OPENSTACK_MANILA_FEATURES section. These will
  # be merged with user-provided options when the _90_manila_shares.py.erb
  # template is interpolated.
  $manila_defaults = {
    'enable_share_groups'                     => true,
    'enable_replication'                      => true,
    'enable_migration'                        => true,
    'enable_public_share_type_creation'       => true,
    'enable_public_share_group_type_creation' => true,
    'enable_public_shares'                    => true,
    'enabled_share_protocols'                 => ['NFS', 'CIFS', 'GlusterFS', 'HDFS', 'CephFS', 'MapRFS'],
  }
  $manila_options_real = merge($manila_defaults, $manila_options)

  $config_file = "${::horizon::params::conf_d_dir}/_90_manila_shares.py"

  package { 'manila-dashboard':
    ensure => $::horizon::package_ensure,
    name   => $::horizon::params::manila_dashboard_package_name,
    tag    => ['openstack', 'horizon-package'],
  }

  concat { $config_file:
    mode    => '0640',
    owner   => $::horizon::params::wsgi_user,
    group   => $::horizon::params::wsgi_group,
    require => File[$::horizon::params::conf_d_dir],
    tag     => ['django-config'],
  }

  concat::fragment { '_90_manila_shares.py':
    target  => $config_file,
    content => template('horizon/_90_manila_shares.py.erb'),
    order   => '50',
  }
}
