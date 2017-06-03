#
class cognos::install::prereqs{

  # centos 7
  $prereq_packages = [
    'unzip',
    'glibc.i686',
    'glibc.x86_64',
    'nspr.x86_64',
    'nss.x86_64',
    'motif.i686',
    'motif.x86_64',
    'libstdc++',
    'nss-tools',
  ]

  $prereq_packages.each | $pkg_name | {
    if($pkg_name) {
      ensure_resource(
        'package',
        $pkg_name,
        { ensure => 'present' },
      )
    }
  }

}