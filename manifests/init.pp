class ssh {
    $permit_root_login = hiera('permit_root_login')

    package { 'openssh-server':
        ensure => present
    }

    file { '/etc/ssh/sshd_config':
        owner => root,
        group => root,
        mode => '0644',
        notify => Service['ssh'],
        require => Package['openssh-server'],
    }

    augeas { "sshd_config":
        context => "/files/etc/ssh/sshd_config",
        changes => [
            "set PermitRootLogin $permit_root_login",
        ],
    }

    service { 'ssh':
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => [
            File['/etc/ssh/sshd_config'],
            Package['openssh-server']
        ],
    }

    include ssh::known_hosts
}
