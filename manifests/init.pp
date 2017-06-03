# Class: cognos
# ===========================
#
class cognos(
  $installer_target_dir         = '/opt/ibm/cognos/analytics',
  $installer_source_dir         = '/vagrant',
  $installer_filename           = 'ca_srv_lnxi38664_11.0.5.16111917.bin',
  $installer_timeout            = 600,
  $install_app_tier             = true,
  $install_gateway              = true,
  $install_prereq_packages      = true,
  $install_symlinks             = true,
  $cognos_user                  = 'cognos',
  $cognos_user_uid              = '4979',
  $cognos_user_password         = 'vagrant',
  $cognos_db_user               = 'cog_db2',
  $cognos_db_user_uid           = '4980',
  $cognos_db_user_password      = 'vagrant',
  $cog_users_password_salt      = 'vagrant',
  $cognos_db_instance_user      = 'db2inst1',
  $pmp_max_memory               = 1024,
  $dispatcher_max_memory        = 4096,
  $sort_memory                  = 32,
  $external_dispatcher_uri_port = 443,
  $service_max_tries            = 600,
  $service_wait_interval        = 10000,
  $manage_firewall              = true,
  $configure_db2_cm_db          = true,
  $db2_install_path             = '/opt/ibm/db2/V10.1',
  $enable_debug_logging         = true,
  $enable_delivery_service      = false,
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
