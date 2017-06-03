#
class cognos::install::prep {

  group{$cognos::cognos_user:
    gid => $cognos::cognos_user_uid,
  }

  group{$cognos::cognos_db_user:
    gid => $cognos::cognos_db_user_uid,
  }

  user{$cognos::cognos_user:
    uid      => $cognos::cognos_user_uid,
    groups   => $cognos::cognos_user,
    password => pw_hash($cognos::cognos_user_password,'SHA-512', $cognos::cog_users_password_salt),
    require  => Group[$cognos::cognos_user],
  }

  user{$cognos::cognos_db_user:
    uid      => $cognos::cognos_db_user_uid,
    groups   => $cognos::cognos_db_user,
    password => pw_hash($cognos::cognos_db_user_password,'sha-512', $cognos::cog_users_password_salt),
    shell    => '/bin/bash',
    comment  => 'cognos db2 user',
    require  => Group[$cognos::cognos_db_user],
  }

  # Cognos won't start without this host entry
  ensure_resource(
    'host',
    $::fqdn,
    { ip => '127.0.0.1' }
  )

}