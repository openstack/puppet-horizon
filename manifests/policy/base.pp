# == Define horizon::policy::base
#
# Manage a policy file for Horizon
#
# == Parameters
#
# [*policy_file*]
#   (Optional) Name to the policy file.
#   Defaults to $name
#
# [*policies*]
#   (Optional) Set of policies to configure
#
# [*file_mode*]
#   (Optional) Permission mode for the policy file
#   Defaults to '0640'
#
# [*file_format*]
#   (Optional) Format for file contents. Valid value is 'yaml'
#   Defaults to 'yaml'.
#
# [*purge_config*]
#   (Optional) Whether to set only the specified policy rules in the policy
#   file.
#   Defaults to false.
#
define horizon::policy::base(
  String[1] $policy_file           = $name,
  Openstacklib::Policies $policies = {},
  Stdlib::Filemode $file_mode      = '0640',
  Enum['yaml'] $file_format        = 'yaml',
  Boolean $purge_config            = false,
) {
  include horizon::deps
  include horizon::params

  if !defined(Class[horizon]){
    fail('The horizon class should be included in advance')
  }

  $policy_files_path = $horizon::policy_files_path_real
  if ! $policy_files_path {
    # In Ubuntu/Debian, the default policies files are located in source
    # directories, and the path should be updated to more appropriate path
    # like /etc.
    fail('Please set the horizon::policy_files_path parameter to customize policies')
  }

  openstacklib::policy { "${policy_files_path}/${policy_file}" :
    policies     => $policies,
    file_user    => $horizon::params::wsgi_user,
    file_group   => $horizon::params::wsgi_group,
    file_mode    => $file_mode,
    file_format  => $file_format,
    purge_config => $purge_config,
    tag          => 'horizon',
  }
}
