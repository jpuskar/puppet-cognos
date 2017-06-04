#
class cognos::cm_db::db2 {

  # Cognos DB2 CM SQL File
  $cognos_db_file = "/home/${cognos::db2_instance_user}/create_cognos_db.sql"
  file{$cognos_db_file:
    content => template('cognos/create_cognos_db.sql.erb'),
    mode    => '0755',
    owner   => $cognos::db2_instance_user,
    group   => $cognos::db2_instance_user,
  }

  # Configure Cognos ContentDb
  exec{'configure_cognos_db2_cm_db':
    command => "${cognos::db2_install_path}/bin/db2 -tvf ${cognos_db_file}",
    user    => $cognos::db2_instance_user,
    cwd     => "/home/${cognos::db2_instance_user}",
    timeout => 600,
    unless  => "${cognos::db2_install_path}/bin/db2 list db directory | grep \"Database name\" | grep \"= CM\"",
    require => File[$cognos_db_file],
  }

  # DB2 drivers
  exec{'install_db2_java_driver_cognos':
    command  => "cp ${cognos::db2_install_path}/java/db2jcc.jar ${cognos::installer_target_dir}/drivers",
    unless   => "test -f ${cognos::installer_target_dir}/drivers/db2jcc.jar",
    provider => 'shell',
  }
  -> file{"${cognos::installer_target_dir}/drivers/db2jcc.jar":
    mode    => '0775',
    owner   => $cognos::cognos_user,
    group   => $cognos::cognos_user,
    require => Exec['install_db2_java_driver_cognos'],
  }

}