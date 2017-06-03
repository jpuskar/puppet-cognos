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
    firewalld_port { 'Open port 8080 in the public zone':
      ensure   => present,
      zone     => 'public',
      port     => 9300,
      protocol => 'tcp',
    }

    # firewall { '1205 [cognos::config] allow cognos gateway https inbound':
    #   chain  => 'INPUT',
    #   proto  => 'tcp',
    #   dport  => 443,
    #   state  => 'NEW',
    #   action => 'accept',
    # }
    #
    # firewall { '3505 [cognos::config] allow cognos gateway https outbound':
    #   chain  => 'OUTPUT',
    #   proto  => 'tcp',
    #   dport  => 443,
    #   state  => 'NEW',
    #   action => 'accept',
    # }
  }

  # Cognos config file
  file{"${cognos::installer_target_dir}/configuration/cogstartup.puppet.xml":
    content => template('cognos/cognos11_config.xml.erb'),
    mode    => '0755',
    before  => Exec['apply_new_cognos_config'],
    notify  => Exec['apply_new_cognos_config'],
  }

  # Configure Cognos
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

}