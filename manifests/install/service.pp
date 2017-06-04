#
class cognos::install::service {

  $base_ld_library_path = "${cognos::installer_target_dir}/cgi-bin"
  if $cognos::configure_db2_cm_db {
    $final_ld_library_path = "${base_ld_library_path}:${cognos::db2_install_path}/sqllib/lib32/"
  } else {
    $final_ld_library_path = $base_ld_library_path
  }

  if $cognos::systemd_env_java_home {
    $final_java_home = $cognos::systemd_env_java_home
  } else {
    $final_java_home = "${cognos::installer_target_dir}/jre"
  }
  # Cognos unit file
  file{'/etc/systemd/system/cognos.service':
    content => template('cognos/cognos.service.erb'),
    mode    => '0644',
    notify  => Exec['cognos_reload_systemd_units'],
  }
  exec{'cognos_reload_systemd_units':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    provider    => 'shell',
  }
  ~> service{'cognos':
    ensure => running,
    enable => true,
  }
}
