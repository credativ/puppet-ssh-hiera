class ssh::known_hosts (
    $manage,
    $manage_hostkey
    ) {

    if $manage_hostkey {
        $authorized_keys = ssh_keygen({ public => 'all', dir => 'ssh/hostkeys'})
        # if we are managing hostkeys, we are using its known_hosts file
        file { '/etc/ssh/ssh_known_hosts':
            mode    => '0644',
            content => $authorized_keys
        }

    } else {
        # Export our own ssh key
        @@sshkey { $::hostname:
            host_aliases    => [$::fqdn, $::ipaddress],
            type            => rsa,
            key             => $::sshrsakey
        }

        Sshkey <<| |>>
        
        # WORKAROUND FOR http://projects.reductivelabs.com/issues/2014
        # ssh_known_hosts file is created with wrong permissions
        file { '/etc/ssh/ssh_known_hosts':
            mode => '0644'
        }
    }
    
}
