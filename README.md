# Puppet module: ssh

This is a puppet module for `openssh-server` based on the common credativ puppet modules
layout (https://github.com/credativ/puppet-module-template)

## Requirements
This module template requires the params_lookup function as found in the
example42 puppi module (github.com/credativ/puppet-example42lib)

## Install

if you are using librarian or r10k, simply add the following line into your Puppetfile:

    mod 'credativ/ssh', :git => 'git://github.com/credativ/puppet-ssh-hiera.git'

## Usage

Most common use case for the module is to just include it and configure it
in the hiera backend.

    ssh_groups:
      www-data:
        gid: 33
    ssh_users:
      johndoe:
        comment: "John Doe"
        groups: ["sudo"]
        shell: "/bin/bash"
        pwhash: '$6$wVWsmNcN$t4G3kuGyWvdtQ.X51jZGPdSZaB.5wA/6F7qzyJ4CaUmasZZA94v2qw9vZueyXRSeRBWmHxCKBdiLIK35lyK3y0'
        uid: 1002
        gid: 1002
        ssh_key:
          type: "ssh-rsa"
          comment: "john@pc"
          key: "AAAAB3NzaC1yc2EAAAADAQABAAABAQDIRsDur48bb8kTvrtg9uSzu722964xQ+4Pnu...

So including it via the following line of code or in a ENC declaration
(apart from proper configuration in hiera or top-scope variables)
is usually enough:

      class { 'ssh': }

This module does not create a configuration file itself, but it is able to manage a few common settings.

Suppose your `hiera.yaml` looks like this:

      ---
      :hierarchy:
          - %{operatingsystem}
          - common
      :backends:
          - yaml
      :yaml:
          :datadir: /etc/puppet/hieradata/%{::environment}

Then hiera using `hiera_hash` will search for all `ssh_users` variables in all relevant files. So that you can define `debian_admin` user specific for Debian servers in `Debian.yaml` and all default user accounts will be in `common.yaml`.


### Configuring PermitRootLogin

Often systems may not want to permit root login via SSH. This module is
able to set this option via augeas. The parameter is a global parameter
called `permit_root_login`, so it always has the same name (contrary
to other parameters, which are usually prefixed with the module name if
configured via global parameters or hiera).

By default the module disables root login.

To change it, having something like this in hiera works:

in `common.yaml` (depends on your `hiera.yaml` config)

    permit_root_login: 'yes'

or 

    ssh_permit_root_login: 'yes'
