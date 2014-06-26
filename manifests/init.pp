# = Class: ssh
#
# Manage SSH on a system
#
# == Features:
# 
# - Install sshd and configure some common settings (e.g. PermitRootLogin)
# - Manage ssh users and groups
# - Manage a global known_hosts file
#
# == Requirements:
# 
#  - This module makes use of the example42 functions in the puppi module
#    (https://github.com/credativ/puppet-example42lib)
#  - The module makes use of puppets storeconfig feature. So puppet on both
#    master and agents must be configured accordingly.
#
# == Parameters:
# 
# [*ensure*]
#    What state to ensure for the package. Accepts the same values
#    as the parameter of the same name for a package type.
#    Default: present
#
#  [*ensure_running*]
#    Wether to ensure running sshd or not.
#    Default: running
#
#  [*ensure_enabled*]
#    Wether to ensure that sshd is started on boot or not.
#    Default: true
#
# [*manage_hostkey*]
#    Wether to manage the hostkey) or not. This is required for manage_known_hosts
#    without storeconfig/puppetdb to work.
#    Default: false

#
# [*manage_known_hosts*]
#    Wether to manage a global known_hosts file or not.
#    Default: true
#
# [*manage_users*]
#    Wether to manage users or not.
#    Default: false
#
# [*manage_groups*]
#    Wether to manage groups or not.
#    Default: false
#
# [*permit_root_login*]
#    Wether to permit root login or not. This is a global option. If
#    configuring it from hiera, make sure not to prefix it with the
#    module name.
#
# [*listen_address*]
#    Define the address the sshd should listen on.
#    Default: 0.0.0.0
#
# [*users]
#    A hash with the users that shall be managed.
#
# [*groups*]
#    A hash with the groups that shall be managed
#
# == Author:
# 
#    Patrick Schoenfeld <patrick.schoenfeld@credativ.de>
#
class ssh (
    $ensure             = params_lookup('ensure'),
    $ensure_running     = params_lookup('ensure_running'),
    $ensure_enabled     = params_lookup('ensure_enabled'),
    $permit_root_login  = params_lookup('permit_root_login', 'global'),
    $listen_address     = params_lookup('listen_address'),
    $manage_known_hosts = params_lookup('manage_known_hosts'),
    $manage_users       = params_lookup('manage_users'),
    $manage_groups      = params_lookup('manage_groups'),
    $manage_hostkey     = params_lookup('manage_hostkey'),
    $hostaliases        = params_lookup('hostaliases'),
    $users              = params_lookup('users'),
    $groups             = params_lookup('groups'),
    $service_name       = params_lookup('service_name'),
    $options            = params_lookup('options')

    ) inherits ssh::params {

    package { 'openssh-server':
        ensure => $ensure,
    }

    file { '/etc/ssh/sshd_config':
        owner   => root,
        group   => root,
        mode    => '0644',
        notify  => Service[$service_name],
        require => Package['openssh-server'],
    }

    $additional_ssh_options = inline_template("
set PermitRootLogin $permit_root_login
set ListenAddress $listen_address
<% if @options -%>
<% options.each do |k, v| -%>
set <%= k %> <%= v %>
<% end -%>
<% end -%>
")

    augeas { 'sshd_config':
        context => '/files/etc/ssh/sshd_config',
        changes => $additional_ssh_options
        #split('\n', $ssh_options))
        
    }

    service { $service_name:
        ensure      => $ensure_running,
        enable      => $ensure_enabled,
        hasrestart  => true,
        hasstatus   => true,
        require     => [
            File['/etc/ssh/sshd_config'],
            Package['openssh-server']
        ],
    }

    class { 'ssh::groups':
        manage => $manage_groups,
        groups => $groups,
    } ~> # first groups, then users
    class { 'ssh::users':
        manage => $manage_users,
        users  => $users,
    }

    class { 'ssh::hostkey':
        manage_hostkey  => $manage_hostkey,
        hostaliases     => $hostaliases
    } ~>
    class { 'ssh::known_hosts':
        manage          => $manage_known_hosts,
        manage_hostkey  => $manage_hostkey,
    }
}
