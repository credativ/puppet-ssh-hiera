class ssh::known_hosts {
    @@sshkey { $hostname: 
        host_aliases => [$fqdn, $ipaddress],
        type => rsa,
        key => $sshrsakey
    }

    Sshkey <<| |>>

    # WORKAROUND FOR http://projects.reductivelabs.com/issues/2014
    # ssh_known_hosts file is created with wrong permissions
    file { "/etc/ssh/ssh_known_hosts":
        mode => '0644'
    }
}
