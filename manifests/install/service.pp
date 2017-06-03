#
class cognos::install::service {
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
