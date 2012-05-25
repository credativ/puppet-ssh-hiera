class puppet-ssh-hiera {
  include ssh::known_hosts
  $permit_root_login = hiera('permit_root_login')

  augeas { 'sshd_config':
    context => '/files/etc/ssh/sshd_config',
    changes => [
      "set PermitRootLogin $permit_root_login",
    ],
  }

  file { '/etc/ssh/sshd_config':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'sshd_config',
    notify  => Service['ssh'],
    require => Package['openssh-server'],
  }

  package { 'openssh-server':
    ensure => present
  }

  service { 'ssh':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [
      File['sshd_config'],
      Package['openssh-server']
    ],
  }
}
