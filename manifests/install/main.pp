#
class cognos::install::main {

  # variables for response file
  if $cognos::install_app_tier {
    $install_app_tier_int = 1
  } else {
    $install_app_tier_int = 0
  }
  if $cognos::install_gateway {
    $install_gateway_int = 1
  } else {
    $install_gateway_int = 0
  }

  # Input validation
  # TODO: swap to validate_legacy()
  #validate_legacy(Optional[String], 'validate_re', $db2::instance_user_password, ['^(?!vagrant$).*$'])
  validate_legacy(
    Optional[String],
    'validate_re',
    $cognos::cognos_user,
    '^[a-zA-Z0-9]{1,8}$',   # CHAR(8) && !/w && ![A-Z]
  )
  validate_legacy(
    Optional[String],
    'validate_re',
    $cognos::cognos_db_user,
    '^[a-zA-Z0-9_]{1,8}$',   # CHAR(8) && !/w && ![A-Z]
  )

  # If we're not in vagrant, then assert that our passwords aren't 'vagrant'.
  if $::is_vagrant != 'true' { # lint:ignore:quoted_booleans
    validate_legacy(
      Optional[String],
      'validate_re',
      $cognos::cognos_user,
      '^(?!vagrant$).*$',
    )

    validate_legacy(
      Optional[String],
      'validate_re',
      $cognos::cognos_db_user,
      '^(?!vagrant$).*$',
    )

    validate_legacy(
      Optional[String],
      'validate_re',
      $cognos::cog_users_password_salt,
      '^(?!vagrant$).*$',
    )
  }

  # Cognos response file
  $response_file_name = "${cognos::installer_source_dir}/cognos_11_installer.properties"
  file{$response_file_name:
    content => template('cognos/cognos_11.rsp.erb'),
    mode    => '0755',
  }

  # Install Cognos
  $cog_install_cmd = @("END_COG_INSTALL_CMD"/$)
export LAX_DEBUG=true
./${cognos::installer_source_dir}/${cognos::installer_filename} -f ${response_file_name} -i silent
  | END_COG_INSTALL_CMD

  $cog_unless_cmd = @("END_COG_UNLESS_CMD"/$)
  test -f ${cognos::installer_target_dir}/cmplst.txt && \
  cat ${cognos::installer_target_dir}/cmplst.txt | grep -i PSPORTLETS_name=IBM\ Cognos\ Portal\ Services
  | END_COG_UNLESS_CMD

  exec{'install_cognos':
    command  => $cog_install_cmd,
    provider => 'shell',
    cwd      => $cognos::installer_source_dir,
    timeout  => $cognos::installer_timeout,
    unless   => $cog_unless_cmd,
    require  => [
      File[$response_file_name],
    ],
    before   => Exec['chown_cognos_install_dir'],
  }

  exec{'chown_cognos_install_dir':
    command  => "chown -R ${cognos::cognos_user}:${cognos::cognos_user} /opt/ibm/cognos",
    unless   => "ls -l ${cognos::installer_target_dir} | grep \"${cognos::cognos_user}\\:${cognos::cognos_user}\"",
    provider => 'shell',
  }

}
