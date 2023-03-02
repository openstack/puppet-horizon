#
# Copyright (C) 2018 Binero
#
# Author: Tobias Urdin <tobias.urdin@binero.se>
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
# == Define: horizon::dashboard
#
# This resource installs additional horizon dashboard which is not
# shipped with the horizon packages, but as additional packages.
#
# == Parameters:
#
# [*ensure*]
#   (Optional) The ensure state of the dashboard package.
#   Defaults to present
#
# == Example:
#
# This will install the correct cloudkitty-dashboard package for your deployment.
# horizon::dashboard { 'cloudkitty': }
#
define horizon::dashboard (
  $ensure = 'present',
) {

  $dashboard = downcase($name)

  if $dashboard in ['designate', 'heat', 'octavia', 'manila'] {
    warning("Use the horizon::dashboard::${dashboard} class instead. \
The class allows more flexible customization of the ${dashboard} dashboard.")
  }

  case $facts['os']['family'] {
    'Debian': {
      $dashboard_package_name = "python3-${dashboard}-dashboard"
    }
    'RedHat': {
      $dashboard_package_name = "openstack-${dashboard}-ui"
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }

  ensure_packages($dashboard_package_name, {
    'ensure'  => $ensure,
    'tag'     => ['horizon-dashboard-package']
  })
}
