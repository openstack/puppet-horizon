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
# == Class: horizon::dashboards::cloudkitty
#
# Manage parameters of cloudkitty-dashboard
#
# === Parameters:
#
#  [*rate_prefix*]
#    (optional) Prefix of rates.
#    Defaults to undef
#
#  [*rate_postfix*]
#    (optional) Postfix of rates.
#    Defaults to undef
#
#  [*quotation_service*]
#    (optional) Service used for quotation.
#    Defaults to undef
#
class horizon::dashboards::cloudkitty (
  $rate_prefix       = undef,
  $rate_postfix      = undef,
  $quotation_service = undef,
) {
  include horizon::deps
  include horizon::params

  # The horizon class should be included so that some common parameters
  # can be picked here.
  if ! defined(Class[horizon]) {
    fail('The horizon class should be included before the horizon::dashboards::cloudkitty class')
  }
  $log_handlers = $horizon::log_handlers
  $log_level    = $horizon::log_level

  $config_file = "${horizon::params::conf_d_dir}/_3200_rating_settings.py"

  package { 'cloudkitty-dashboard':
    ensure => $horizon::package_ensure,
    name   => $horizon::params::cloudkitty_dashboard_package_name,
    tag    => ['openstack', 'horizon-package'],
  }

  concat { $config_file:
    mode    => '0640',
    owner   => $horizon::params::wsgi_user,
    group   => $horizon::params::wsgi_group,
    require => File[$horizon::params::conf_d_dir],
    tag     => ['django-config'],
  }

  concat::fragment { '_3200_rating_settings.py':
    target  => $config_file,
    content => template('horizon/_3200_rating_settings.py.erb'),
    order   => '50',
  }
}
