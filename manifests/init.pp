# = Class: ssh
#
# Manage SSH on a system
#
# == Actions:
#
# Manage SSH on a system, including distributing hostkeys.
#
# == Requirements:
#
#    - params_lookup function from example42lib

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
