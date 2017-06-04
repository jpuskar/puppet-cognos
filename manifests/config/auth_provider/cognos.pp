#
define cognos::config::auth_provider::cognos(
  $allow_anon = false,
  $disable_cm = false,
  $instance_name = $title,
) {

  concat::fragment {"auth_provider_${instance_name}":
    content => template('cognos/config/auth_provider/cogconfig_fragment_auth_provider_cognos.xml.erb'),
    target  => "${cognos::installer_target_dir}/configuration/cogstartup.puppet.xml",
    order   => '10',
  }

}