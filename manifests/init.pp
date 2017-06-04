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
# ldaps_certs_to_trust example:
# $cert_db_path = '/opt/ibm/cognos/analytics/configuration'
# $ldaps_public_certs_to_trust = [
#   {
#     'ipa_root_cert' => {
#       source_file  => '/etc/pki/ca-trust/source/anchors/ipa_root_cert_pub.pem',
#       cert_db_path => $cert_db_path,
#     }
#   },
#   {
#     'ipa_dc1_cert' => {
#       source_file  => '/etc/pki/ca-trust/source/anchors/ipa_dc1_cert_pub.pem',
#       cert_db_path => $cert_db_path,
#     }
#   }
# ]
#
# TODO:
#  * Write tests for ldaps_public_certs_to_trust
#  * cogconfig.puppet.xml should be encrypted or at least set to root-only.
#  * Implement XML array param for IPA auth_provider parameter 'advancedProperties'
#  * Implement XML array param for IPA auth_provider parameter 'customProperties'
#
class cognos(
  Optional[Boolean] $allow_anon                   = true,
  Optional[Array]   $auth_provider_config         = [],
  Optional[Integer] $bv_max_attachment_size       = 1024,
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
  Optional[String]  $default_font                 = 'Andale WT',
  Optional[Boolean] $disable_cm                   = false,
  Optional[Integer] $dispatcher_max_memory        = 4096,
  Optional[String]  $edition                      = 'enterprise',
  Optional[String]  $email_encoding               = 'utf-8',
  Optional[Boolean] $enable_debug_logging         = true,
  Optional[Boolean] $enable_delivery_service      = false,
  Optional[Integer] $external_dispatcher_uri_port = 443,
  Optional[Array]   $firewall_ports_to_open       = [9300],
  Optional[String]  $gateway                      = "http://${::fqdn}:9300/bi/v1/disp",
  Optional[Array]   $gateway_dispatcher_url_list  = ['http://127.0.0.1:9300/bi/v1/disp'],
  Optional[String]  $installer_target_dir         = '/opt/ibm/cognos/analytics',
  Optional[String]  $installer_source_dir         = '/vagrant',
  Optional[String]  $installer_filename           = 'ca_srv_lnxi38664_11.0.6.17031315.bin',
  Optional[Integer] $installer_timeout            = 600,
  Optional[Boolean] $install_app_tier             = true,
  Optional[Boolean] $install_gateway              = true,
  Optional[Boolean] $install_prereq_packages      = true,
  Optional[Boolean] $install_symlinks             = true,
  Optional[Array]   $ldaps_public_certs_to_trust  = [],
  Optional[String]  $license_type                 = 'production',
  Optional[Boolean] $manage_firewall              = true,
  Optional[Boolean] $manage_ldaps_cert_db         = false,
  Optional[Integer] $pmp_max_memory               = 1024,
  Optional[String]  $release_type                 = 'ga',
  Optional[String]  $server_locale                = 'en',
  Optional[String]  $server_time_zone_id          = 'Europe/Dublin',
  Optional[Integer] $service_max_tries            = 600,
  Optional[Integer] $service_wait_interval        = 10000,
  Optional[Integer] $sort_memory                  = 32,
  Optional[String]  $systemd_env_java_home        = undef,
  Optional[Boolean] $systemd_service_accounting   = true,
  Optional[Integer] $systemd_service_restart_time = 900,
  Optional[Integer] $systemd_service_nofile_limit = 65535,
) {

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
