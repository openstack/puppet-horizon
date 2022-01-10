# == Class horizon::policy
#
# Manage policy files for Horizon
#
# == Parameters
#
# [*file_mode*]
#   (Optional) Permission mode for the policy file.
#   Defaults to '0640'
#
# [*file_format*]
#   (Optional) Format for file contents.
#   Defaults to 'yaml'.
#
# [*purge_config*]
#   (Optional) Whether to set only the specified policy rules in the policy
#   file.
#   Defaults to false.
#
# [*cinder_policies*]
#   (Optional) Set of cinder policies to configure.
#   Defaults to {}
#
# [*glance_policies*]
#   (Optional) Set of glance policies to configure.
#   Defaults to {}
#
# [*keystone_policies*]
#   (Optional) Set of keystone policies to configure.
#   Defaults to {}
#
# [*neutron_policies*]
#   (Optional) Set of neutron policies to configure.
#   Defaults to {}
#
# [*nova_policies*]
#   (Optional) Set of nova policies to configure.
#   Defaults to {}
#
class horizon::policy(
  # common parameters
  $file_mode            = '0640',
  $file_format          = 'yaml',
  $purge_config         = false,
  # service specific parameters
  $cinder_policies      = {},
  $glance_policies      = {},
  $keystone_policies    = {},
  $neutron_policies     = {},
  $nova_policies        = {},
) {
  include horizon::deps

  if !defined(Class[horizon]){
    fail('The horizon class should be included in advance')
  }

  $policy_files = pick($::horizon::policy_files, {})
  $policy_files_default = {
    'identity' => 'keystone_policy.yaml',
    'compute'  => 'nova_policy.yaml',
    'volume'   => 'cinder_policy.yaml',
    'image'    => 'glance_policy.yaml',
    'network'  => 'neutron_policy.yaml',
  }
  $policy_files_real = merge($policy_files_default, $policy_files)

  $policy_resources = {
    $policy_files_real['volume']   => { 'policies' => $cinder_policies },
    $policy_files_real['image']    => { 'policies' => $glance_policies },
    $policy_files_real['identity'] => { 'policies' => $keystone_policies },
    $policy_files_real['network']  => { 'policies' => $neutron_policies },
    $policy_files_real['compute']  => { 'policies' => $nova_policies },
  }

  $policy_defaults = {
    'file_mode'    => $file_mode,
    'file_format'  => $file_format,
    'purge_config' => $purge_config
  }

  create_resources('horizon::policy::base', $policy_resources, $policy_defaults)
}
