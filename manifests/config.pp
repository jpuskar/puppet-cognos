#
class cognos::config{
  # Startup wait times. If unset, Cognos may fail to start.
  file_line { 'Cognos_ServiceMaxTries':
    ensure => present,
    path   => '/opt/ibm/cognos/analytics/configuration/cogconfig.prefs',
    line   => "ServiceMaxTries=${cognos::service_max_tries}",
    match  => '^ServiceMaxTries*',
  }
  file_line { 'Cognos_ServiceWaitInverval':
    ensure => present,
    path   => '/opt/ibm/cognos/analytics/configuration/cogconfig.prefs',
    line   => "ServiceWaitInterval=${cognos::service_wait_interval}",
    match  => '^ServiceWaitInterval*',
  }

  if $cognos::enable_debug_logging {
    file_line { 'cognos_log4j_axis_debug':
      ensure => present,
      path   => '/opt/ibm/cognos/analytics/bin/log4j.properties',
      line   => 'log4j.logger.org.apache.axis=DEBUG, CONSOLE',
      match  => '^log4j\.logger\.org\.apache\.axis=+',
    }
    file_line { 'cognos_log4j_axis_enterprise_debug':
      ensure => present,
      path   => '/opt/ibm/cognos/analytics/bin/log4j.properties',
      line   => 'log4j.logger.org.apache.axis.enterprise=DEBUG, CONSOLE',
      match  => '^log4j\.logger\.org\.apache\.axis\.enterprise=+',
    }
    file_line { 'cognos_log4j_appender_console_debug':
      ensure => present,
      path   => '/opt/ibm/cognos/analytics/bin/log4j.properties',
      line   => 'log4j.appender.CONSOLE.Threshold=DEBUG',
      match  => '^log4j\.appender\.CONSOLE\.Threshold=+',
    }
    file_line { 'cognos_log4j_appender_logfile_debug':
      ensure => present,
      path   => '/opt/ibm/cognos/analytics/bin/log4j.properties',
      line   => 'log4j.appender.LOGFILE.Threshold=DEBUG',
      match  => '^log4j\.appender\.LOGFILE\.Threshold=+',
    }
    file_line { 'cognos_cogconfigipf_info':
      ensure   => present,
      path     => '/opt/ibm/cognos/analytics/configuration/cogconfigipf.xml',
      line     => '                <level value="info"/>',
      match    => '^(\s)+\<level\ value=',
      multiple => true,
    }
  }

  if $cognos::manage_firewall {
    include '::firewalld'
    $cognos::firewall_ports_to_open.each | $cur_port | {
      firewalld_port { "[cognos::config] Open port ${cur_port} in the public zone":
        ensure   => present,
        zone     => 'public',
        port     => $cur_port,
        protocol => 'tcp',
      }
    }
  }

  # Auth Providers
  if !empty($cognos::auth_provider_config) {
    $cognos::auth_provider_config.each | $instance_config | {
      ensure_resources(
        'cognos::config::auth_provider',
        $instance_config
      )
    }
  }

  # Acutal config file
  concat { "${cognos::installer_target_dir}/configuration/cogstartup.puppet.xml":
    owner  => $cognos::cognos_user,
    group  => $cognos::cognos_user,
    mode   => '0644',
    notify => Exec['apply_new_cognos_config'],
  }

  concat::fragment {'cogconfig_base_pre':
    content => template('cognos/config/cogconfig_fragment_05.xml.erb'),
    target  => "${cognos::installer_target_dir}/configuration/cogstartup.puppet.xml",
    order   => '05',
  }

  concat::fragment {'cogconfig_base_post':
    content => template('cognos/config/cogconfig_fragment_20.xml.erb'),
    target  => "${cognos::installer_target_dir}/configuration/cogstartup.puppet.xml",
    order   => '20',
  }

  # Apply config file to Cognos
  $cog_conf_cmd = @("END_COG_CONF_CMD"/$)
systemctl stop cognos || true
cp ${cognos::installer_target_dir}/configuration/cogstartup.puppet.xml \
  ${cognos::installer_target_dir}/configuration/cogstartup.xml
chown ${cognos::cognos_user}:${cognos::cognos_user} \
  ${cognos::installer_target_dir}/configuration/cogstartup.xml
  | END_COG_CONF_CMD

  exec{'apply_new_cognos_config':
    command     => $cog_conf_cmd,
    provider    => 'shell',
    refreshonly => true,
    notify      => Service['cognos'],
    require     => Concat_file["${cognos::installer_target_dir}/configuration/cogstartup.puppet.xml"],
  }

  # Add symlinks for intuitive log and config locations
  if $cognos::install_symlinks {
    file { '/etc/cognos':
      ensure => 'directory',
    }
    -> file { '/etc/cognos/configuration':
      ensure => 'link',
      target => '/opt/ibm/cognos/analytics/configuration',
    }

    file { '/var/log/cognos':
      ensure => 'directory',
    }
    -> file { '/var/log/cognos/common':
      ensure => 'link',
      target => '/opt/ibm/cognos/analytics/logs',
    }
    -> file { '/var/log/cognos/wlp':
      ensure => 'link',
      target => '/opt/ibm/cognos/analytics/wlp/usr/servers/cognosserver/logs',
    }
  }

  # LDAPS Certs
  if $cognos::manage_ldaps_cert_db and !is_empty($cognos::ldaps_public_certs_to_trust) {
    include '::nsstools'

    $cognos::ldaps_public_certs_to_trust.each | $cur_cert | {
      ensure_resource(
        'nsstools::create',
        $cur_cert[cert_db_path],
        {
          owner          => $cognos::cognos_user,
          group          => $cognos::cognos_user,
          mode           => '0660',
          password       => 'changeme',
          manage_certdir => false,
          enable_fips    => false,
          before         => Exec['apply_new_cognos_config'],
        }
      )

      nsstools::add_cert { $cur_cert[title]:
        certdir => $cur_cert[cert_db_path],
        cert    => $cur_cert[source_file],
        before  => Exec['apply_new_cognos_config'],
      }
    }
  }

  Cognos::Config::Auth_provider<| |> -> Exec<| title == 'apply_new_cognos_config' |>
}