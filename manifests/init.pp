# Class: cognos
# ===========================
#
# auth_provider_config example
#  class cognos {
#    auth_provider_config => [{
#      'ipa1' => {
#        provider        => 'ipa',
#        provider_config => {
#          base_dn       => 'my_base_dn',
#          bind_username => 'my_bind_user',
#          bind_password => 'my_bind_pwd',
#          host_port     => 'my_dc.ipa.example',
#        },
#      },
#    }],
#  }
#
class cognos(
  Optional[Boolean] $allow_anon                   = true,
  Optional[Array]   $auth_provider_config         = [],
  Optional[String]  $cognos_user                  = 'cognos',
  Optional[String]  $cognos_user_uid              = '4979',
  Optional[String]  $cognos_user_password         = 'vagrant',
  Optional[String]  $cognos_db_user               = 'cog_db2',
  Optional[String]  $cognos_db_user_uid           = '4980',
  Optional[String]  $cognos_db_user_password      = 'vagrant',
  Optional[String]  $cog_users_password_salt      = 'vagrant',
  Optional[Boolean] $configure_db2_cm_db          = true,
  Optional[String]  $db2_install_path             = '/opt/ibm/db2/V10.1',
  Optional[String]  $db2_instance_user            = 'db2inst1',
  Optional[String]  $db2_service_name             = 'db2inst1.service',
  Optional[Boolean] $disable_cm                   = false,
  Optional[Integer] $dispatcher_max_memory        = 4096,
  Optional[Boolean] $enable_debug_logging         = true,
  Optional[Boolean] $enable_delivery_service      = false,
  Optional[Integer] $external_dispatcher_uri_port = 443,
  Optional[String]  $installer_target_dir         = '/opt/ibm/cognos/analytics',
  Optional[String]  $installer_source_dir         = '/vagrant',
  Optional[String]  $installer_filename           = 'ca_srv_lnxi38664_11.0.6.17031315.bin',
  Optional[Integer] $installer_timeout            = 600,
  Optional[Boolean] $install_app_tier             = true,
  Optional[Boolean] $install_gateway              = true,
  Optional[Boolean] $install_prereq_packages      = true,
  Optional[Boolean] $install_symlinks             = true,
  Optional[Boolean] $manage_firewall              = true,
  Optional[Integer] $pmp_max_memory               = 1024,
  Optional[Integer] $service_max_tries            = 600,
  Optional[Integer] $service_wait_interval        = 10000,
  Optional[Integer] $sort_memory                  = 32,
  Optional[String]  $systemd_env_java_home        = undef,
  Optional[Boolean] $systemd_service_accounting   = true,
  Optional[Integer] $systemd_service_restart_time = 900,
) {
  # TODO: cognos::config - file for cogstartup.puppet.xml should be set to root-only.

  # Prereq packages
  if $cognos::install_prereq_packages {
    class {'cognos::install::prereqs':}
  }

  # Other prep items
  -> class {'cognos::install::prep':}

  # Main install
  -> class {'cognos::install::main':}

  # Config
  -> class {'cognos::config':}
  -> if $cognos::configure_db2_cm_db {
    class {'cognos::cm_db::db2':}
  }
  -> class {'cognos::install::service':}
}
