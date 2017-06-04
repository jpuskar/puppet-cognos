#
# example hiera:
# cognos::auth_provider_config:
#  'cognos1':
#     provider: 'cognos'
#     provider_config:
#       allow_anon: true
#   'ipa1':
#     provider: 'ipa'
#
define cognos::config::auth_provider (
  $provider,
  $provider_config,
  $instance_name = $title,
) {

  if $provider == 'ipa' {
    cognos::config::auth_provider::ipa {
      $instance_name:
        * => $provider_config,
    }
  } else {
    fail("The following auth_provider is not supported: ${provider}.")
  }

}