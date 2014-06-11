class ssh::hostkey (
    $manage_hostkey
) {

    if $manage_hostkey {
        # generate and store key on master
        $rsa_priv = ssh_keygen({name => "ssh_host_rsa_${::fqdn}", dir => 'ssh/hostkeys'}) 
        $rsa_pub  = ssh_keygen({name => "ssh_host_rsa_${::fqdn}", dir => 'ssh/hostkeys', public => 'true'}) 

        file { '/etc/ssh/ssh_host_rsa_key':
            owner   => 'root',
            group   => 'root',
            mode    => 0600,
            content => $rsa_priv,
        }
        file { '/etc/ssh/ssh_host_rsa_key.pub':
            owner   => 'root',
            group   => 'root',
            mode    => 0644,
            content => "ssh-rsa $rsa_priv host_rsa_${::hostname}\n",
        }
    }
}


