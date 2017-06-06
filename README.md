# cognos

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with cognos](#setup)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module installs and configures a basic cognos server using db2.

## Setup

### Setup Requirements
+ The cognos install binary must be pre-staged and the parameters named `installer_source_dir` and `installer_filename` configured.
+ DB2 must already be installed\*, and the cognos class parameters `db2_install_path`, `db2_service_name`, and `db2_instance_user` must be correct. See init.pp for the defaults.

\*Note: the provided Vagrantfile will install db2 using the jpuskar-db2 module. See the heading below labeled 'Development'.


## Usage

```puppet
class {'cognos':
  cognos_user_password    => 'mypass',
  cognos_db_user_password => 'mypass',
  cog_users_password_salt => 'random phrase',
  installer_source_dir    => '/root',
  installer_filename      => 'ca_srv_lnxi38664_11.0.5.16111917.bin',
}
```

### TLS / SSL

#### For IPA Authentication
The Cognos certificate database can be managed with this module.
 1. Stage the LDAP server's LDAPS public certificate on the target node.
 1. Use the following pattern for the `ldaps_public_certs_to_trust` parameter.
 
```puppet
$cert_db_path = '/opt/ibm/cognos/analytics/configuration'
$ldaps_public_certs_to_trust = [
  {
    source_file  => '/etc/pki/ca-trust/source/anchors/ipa_root_cert_pub.pem',
    cert_db_path => $cert_db_path,
  },
  {
    source_file  => '/etc/pki/ca-trust/source/anchors/ipa_dc1_cert_pub.pem',
    cert_db_path => $cert_db_path,
  }
]

class {'cognos':
  cognos_user_password        => 'mypass',
  cognos_db_user_password     => 'mypass',
  cog_users_password_salt     => 'random phrase',
  installer_source_dir        => '/root',
  installer_filename          => 'ca_srv_lnxi38664_11.0.5.16111917.bin',
  ldaps_public_certs_to_trust => $ldaps_public_certs_to_trust,
  manage_ldaps_cert_db        => true,
}

```
 

#### For Web
I recommend using nginx in front of Cognos for TLS/SSL. However, it's important to note that if you want to use Webdav with Cognos using Nginx, on Centos this will require re-compiling nginx with webdav support.

Example manifest:

```puppet
include '::selinux'

file {'/etc/pki/tls/certs/mycert.net.crt':
  ensure  => 'present',
  content => 'contents_of_cert_file',
}

file {'/etc/pki/tls/certs/mycert.net.key':
  ensure  => 'present',
  content => 'contents_of_cert_file',
}

class {'::nginx': }
~> class {'cognos':
  cognos_user_password            => 'mypass',
  cognos_db_user_password         => 'mypass',
  cog_users_password_salt         => 'random phrase',
  installer_source_dir            => '/root',
  installer_filename              => 'ca_srv_lnxi38664_11.0.5.16111917.bin',
  firewall_firewall_ports_to_open => [80, 443],
  gateway                         => "https://${::fqdn}:443/bi/v1/disp",
}

selinux::boolean {'httpd_can_network_connect':
  ensure => 'on',
}

selinux::boolean {'httpd_setrlimit':
  ensure => 'on',
}

```

With the following hiera:
```yaml
nginx::nginx_vhosts:
  'cognos':
    server_name:
      - "%{::fqdn}"
    ssl:                  true
    listen_ip:            "%{::networking.ip}"
    ssl_cert:             '/etc/pki/tls/certs/mycert.net.crt'
    ssl_key:              '/etc/pki/tls/private/mycert.net.key'
    use_default_location: false
    rewrite_to_https:     true
    index_files:          []
nginx::nginx_locations:
  '/':
    location:             '/'
    vhost:                'cognos'
    ssl:                  true
    ssl_only:             true
    proxy:                "http://127.0.0.1:9300"
    proxy_set_header:
      - 'X-Forwarded-Proto $scheme'
      - 'Host              $host'
      - 'X-Forwarded-For   $proxy_add_x_forwarded_for'

```


## Reference

### Class parameters

#### `auth_provider_config`

Configures authentication providers. For the full set of provider_config parameters, see the class `cognos::config::auth_provider::ipa`.

Example from a manifest:
```puppet
$auth_providers => {
  'ipa_1' => {
    provider        => 'ipa',
    provider_config => {
      base_dn       => 'my_base_dn',
      bind_username => 'my_bind_user',
      bind_password => 'my_bind_pwd',
      host_port     => 'my_dc.ipa.example',
    }
  }
}

class {'cognos':
  cognos_user_password    => 'mypass',
  cognos_db_user_password => 'mypass',
  cog_users_password_salt => 'random phrase',
  installer_source_dir    => '/root',
  installer_filename      => 'ca_srv_lnxi38664_11.0.5.16111917.bin',
  auth_provider_config    => $auth_providers,
}
```

Example from hiera:
```yaml
cognos::auth_provider_config:
  'ipa_1':
    provider: 'ipa'
    provider_config:
      base_dn: 'my_base_dn'
      bind_username: 'my_bind_user'
      bind_password: 'my_bind_pwd'
      host_port: 'my_dc.ipa.example'
```

Please see the individual manifest files for additional parameters.

## Limitations

This module has only been tested with:
+ Cognos 11.0.5 using DB2 Express V10.1 on Centos 7.3.
+ Cognos 11.0.6 using DB2 Express V10.1 on Centos 7.3.

In addition, it currently does not support:
+ Content Managers other than DB2 running on localhost.
+ Multiple servers / tires.
+ Authentication providers other than IPA via LDAP.

## Development

This module includes a Vagrantfile for easy testing.

Steps to get started:
 1. Install vagrant.
 1. Install virtualbox.
 1. Clone this repo.
 1. Stage the Cognos and DB2 binares.
 1. Run `vagrant up` in a terminal window from the root of the repo.

### Staging the binaries
The Cognos installer file must reside in `./puppet-cognos/vagrant` and the db2 installer must be extracted.

The folder structure must look like the following:
```bash
puppet-cognos/Vagrantfile
puppet-cognos/vagrant/
puppet-cognos/vagrant/ca_srv_lnxi38664_11.0.5.16111917.bin
puppet-cognos/vagrant/v10/
puppet-cognos/vagrant/v10/exp/
puppet-cognos/vagrant/v10/exp/db2setup
```

## Troubleshooting

### Service logs
Systemd will write the output of cogconfig.sh to /var/log/messages. To see what's going on, do this:
```bash
tail -f /var/log/messages
```

Cognos writes logs in many locations, but some good ones to start with are:
```bash
/var/log/cognos/common/cogserver.log
/var/log/cognos/wlp/messages.log
```

Occasionally, logs will show up in:
```bash
/opt/ibm/cognos/analytics/wlp/usr/servers/cognosserver/workarea
```

### Log tools
There's a nice Windows tool available that is available in the Windows versions of cognos, at `\bin\logviewV2.exe`.

I use a local ELK stack running in Docker. I will post the Grok patterns to Github soon.

### BI Filter
For this error, try again in an incognito tab.

```
Error 404: javax.servlet.ServletException: Filter [BIFilter]: com.ibm.bi.platform.commons.web.filters.BIFilter was found, but is corrupt:
```

### On DB2
Make sure db2 is running:
```bash
db2_ps
```

Check the db2 logs:
```bash
db2diag | less
```

To clear database inconsistency, the following has worked on occasion but may be destructive:
```bash
db2_ps # make sure no instances are running
su - db2inst1
ipclean
exit
systemctl start db2inst1
db2_ps # service should now be running
```

### AAA-AUT-0013
```bash
AAA-AUT-0013 The user is already authenticated in all available namespaces.
```

Make sure that `manage_ldaps_cert_db` is `true` and configured correctly. See the above section on TLS.

Also, try checking for more info in `/var/log/cognos/common/cogconfig_response.csv`.
