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
#    Weither to ensure running keepalived or not.
#    Default: running
#
#  [*ensure_enabled*]
#    Weither to ensure that keepalived is started on boot or not.
#    Default: true
#
# [*manage_known_hosts*]
#    Weither to manage a global known_hosts file or not.
#    Default: ture
#
# [*manage_users*]
#    Weither to manage users or not.
#    Default: true
#
# [*manage_groups*]
#    Weither to manage groups or not.
#
# [*permit_root_login*]
#    Weither to permit root login or not. This is a global option. If
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
    $users              = params_lookup('users'),
    $groups             = params_lookup('groups')

    ) inherits ssh::params {

    include augeas

    package { 'openssh-server':
        ensure => $ensure,
    }

    file { '/etc/ssh/sshd_config':
        owner   => root,
        group   => root,
        mode    => '0644',
        notify  => Service['ssh'],
        require => Package['openssh-server'],
    }

    augeas { 'sshd_config':
        context => '/files/etc/ssh/sshd_config',
        changes => [
            "set PermitRootLogin $permit_root_login",
            "set ListenAddress $listen_address"
        ],
    }

    service { 'ssh':
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
    }

    class { 'ssh::users':
        manage => $manage_users,
        users  => $users,
    }

    class { 'ssh::known_hosts':
        manage => $manage_known_hosts,
    }
}
