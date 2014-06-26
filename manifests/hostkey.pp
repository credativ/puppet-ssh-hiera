class ssh::hostkey (
    $manage_hostkey,
    $hostaliases = undef,
) {

    if $manage_hostkey {
        # generate and store key on master
        $rsa_priv = ssh_keygen({request => "private", hostkey => true, hostaliases => $hostaliases, comment => "${::fqdn}", type => 'rsa', name => "ssh_host_rsa_${::fqdn}", dir => 'ssh/hostkeys'}) 
        $rsa_pub  = ssh_keygen({request => "public", type => 'rsa', name => "ssh_host_rsa_${::fqdn}", dir => 'ssh/hostkeys', public => 'true'}) 

        file { '/etc/ssh/ssh_host_rsa_key':
            owner   => 'root',
            group   => 'root',
            mode    => 0600,
            content => $rsa_priv,
            notify  => Service[$ssh::service_name]
        }
        file { '/etc/ssh/ssh_host_rsa_key.pub':
            owner   => 'root',
            group   => 'root',
            mode    => 0644,
            content => "ssh-rsa $rsa_pub host_rsa_${::hostname}\n",
        }

        # generate and store key on master
        $dsa_priv = ssh_keygen({request => "private", hostkey => true, hostaliases => $hostaliases, comment => "${::fqdn}", type => 'dsa', name => "ssh_host_dsa_${::fqdn}", dir => 'ssh/hostkeys'}) 
        $dsa_pub  = ssh_keygen({request => "public", type => 'dsa', name => "ssh_host_dsa_${::fqdn}", dir => 'ssh/hostkeys', public => 'true'}) 

        file { '/etc/ssh/ssh_host_dsa_key':
            owner   => 'root',
            group   => 'root',
            mode    => 0600,
            content => $dsa_priv,
            notify  => Service[$ssh::service_name]
        }
        file { '/etc/ssh/ssh_host_dsa_key.pub':
            owner   => 'root',
            group   => 'root',
            mode    => 0644,
            content => "ssh-dsa $dsa_pub host_dsa_${::hostname}\n",
        }

        # generate and store key on master
        $ecdsa_priv = ssh_keygen({request => "private", hostkey => true, hostaliases => $hostaliases, comment => "${::fqdn}", type => 'ecdsa', name => "ssh_host_ecdsa_${::fqdn}", dir => 'ssh/hostkeys'}) 
        $ecdsa_pub  = ssh_keygen({request => "public", type => 'ecdsa', name => "ssh_host_ecdsa_${::fqdn}", dir => 'ssh/hostkeys', public => 'true'}) 

        file { '/etc/ssh/ssh_host_ecdsa_key':
            owner   => 'root',
            group   => 'root',
            mode    => 0600,
            content => $ecdsa_priv,
            notify  => Service[$ssh::service_name]
        }
        file { '/etc/ssh/ssh_host_ecdsa_key.pub':
            owner   => 'root',
            group   => 'root',
            mode    => 0644,
            content => "ssh-ecdsa $ecdsa_pub host_ecdsa_${::hostname}\n",
        }


    }
}


