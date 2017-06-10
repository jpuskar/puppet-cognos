# puppet-cognos changelog

## v0.1.8
+ Added manage_host_entry parameter to make the host resource optional.

## v0.1.7
+ Fixed another cert database syntax error.

## v0.1.6
+ Fixed ldaps cert database syntax error.

## v0.1.5
+ Lint fixes.

## v0.1.4
+ Fixed bv_max_attachment_size bug.

## v0.1.3
+ Fixed install path bug.

## v.0.1.2
+ Changed vagrant box to bento.
+ Installing puppet via vagrant shell due to puppetlabs-concat version dependency.
+ Fixed gateway uri parameter in cogconfig.xml
+ Fixed ulimit too low via new parameter.
+ Updated readme with nginx SSL info.
+ Added ldaps cert management via nsstools.

## v.0.1.1
+ Added support for IPA auth provider.
+ Updates to systemd unit file:
  + Added java_home.
  + Added systemd_service_accounting.
  + Added ld_library_path
  + Added db2 service options.

## v.0.1.0
+ Initial release.
