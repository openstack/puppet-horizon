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
# == Class: horizon::deps
#
# Horizon anchors and dependency management
#
class horizon::deps {

  anchor { 'horizon::install::begin': }
  -> Package<| tag == 'horizon-package' |>
  ~> anchor { 'horizon::install::end': }
  -> anchor { 'horizon::config::begin': }
  -> Concat<| tag == 'django-config' |>
  ~> anchor { 'horizon::config::end': }
  ~> anchor { 'horizon::compress::begin': }
  ~> Exec<| tag == 'horizon-compress' |>
  ~> anchor { 'horizon::compress::end': }
  ~> anchor { 'horizon::service::begin': }
  ~> Service<| title == 'httpd' |>
  ~> anchor { 'horizon::service::end': }

  # policy config should occur in the config block
  Anchor['horizon::config::begin']
  -> Openstacklib::Policy<| tag == 'horizon' |>
  -> Anchor['horizon::config::end']

  # Regenerate django cache after package update
  Anchor['horizon::install::end'] ~> Anchor['horizon::compress::begin']

  # Installation or config changes will always restart services.
  Anchor['horizon::install::end'] ~> Anchor['horizon::service::begin']
  Anchor['horizon::config::end'] ~> Anchor['horizon::service::begin']
}
