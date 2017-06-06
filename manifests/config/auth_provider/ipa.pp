#
define cognos::config::auth_provider::ipa(
  $base_dn,
  $bind_username,
  $bind_password,
  $host_port,
  $account_business_phone          = 'telephonenumber',
  $account_content_locale          = 'preferredlanguage',
  $account_description             = 'description',
  $account_email                   = 'mail',
  $account_fax_phone               = 'facsimiletelephonenumber',
  $account_given_name              = 'givenName',
  $account_home_phone              = 'homephone',
  $account_mobile_phone            = 'mobile',
  $account_name                    = 'displayName',
  $account_object_class            = 'inetorgperson',
  $account_pager_phone             = 'pager',
  $account_password                = 'userPassword',
  $account_postal_address          = 'postaladdress',
  $account_product_locale          = 'preferredlanguage',
  $account_surname                 = 'sn',
  $account_user_name               = 'uid',
  $allow_empty_password            = false,
  $cam_id_attribute                = 'dn',
  $data_encoding                   = 'UTF-8',
  $external_identity_mapping       = "\${environment(\"REMOTE_USER\")}",
  $folder_description              = 'description',
  $folder_name                     = 'ou',
  $folder_object_class             = 'organizationalunit,nsContainer,ou',
  $group_description               = 'description',
  $group_members                   = 'uniquemember',
  $group_name                      = 'cn',
  $group_object_class              = 'groupofuniquenames',
  $instance_id                     = undef,
  $instance_name                   = $name,
  $size_limit                      = -1,
  $time_out                        = -1,
  $tenancy_info                    = '',
  $tenant_bounding_set_mapping     = '',
  $ssl_certificate_database        = undef,
  $use_external_identity           = false,
  $use_bind_credentials_for_search = true,
  $user_lookup                     = "(uid=\${userID})",
) {

  if $ssl_certificate_database {
    $final_ssl_certificate_database = $ssl_certificate_database
  } else {
    $final_ssl_certificate_database = "${cognos::installer_target_dir}/configuration"
  }

  if $instance_id {
    $final_instance_id = $instance_id
  } else {
    $final_instance_id = "${instance_name}_1"
  }

  concat::fragment {"auth_provider_${instance_name}":
    content => template('cognos/config/auth_provider/cogconfig_fragment_auth_provider_ipa.xml.erb'),
    target  => "${cognos::installer_target_dir}/configuration/cogstartup.puppet.xml",
    order   => '10',
  }

}