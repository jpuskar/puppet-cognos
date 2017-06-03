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

The cognos and db2 v10.1 install binaries must be pre-staged, and the parameter named 'installer_source_dir' configured.

## Usage
The param 'installer_source_dir' expects to find the folder ./exp.
For example, if "/root" is specified, than this should exist: "/root/exp/db2"


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

Please see the individual manifest files for additional parameters.

## Limitations

This module has only been tested with Cognos 11.0.5 using DB2 Express V10.1 on Centos 7.3.

In addition, it currently does not support:
+ Content Managers other than DB2 running on localhost.
+ Multiple servers / tires.
+ Authentication providers of any kind.
## Development

This module includes a Vagrantfile for easy testing. Just install vagrant and virtualbox, clone this repo, and 'vagrant up'.

To stage the DB2 media, make a folder in the repo root called "vagrant", and ensure that the folder structure looks like: "./puppet-cognos/vagrant/exp/db2".
The cognos installer file must also reside in "./puppet-cognos/vagrant".
