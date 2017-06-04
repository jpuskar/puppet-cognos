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
+ DB2 must already be installed, and the cognos class parameters `db2_install_path`, `db2_service_name`, and `db2_instance_user` must be correct. See init.pp for the defaults.

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
puppet-cognos/vagrant/exp/
puppet-cognos/vagrant/exp/db2setup
```
