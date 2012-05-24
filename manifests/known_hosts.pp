class ssh::known_hosts {
    @@sshkey { $hostname: 
        host_aliases => [$fqdn, $ipaddress],
        type => rsa,
        key => $sshrsakey
    }

    Sshkey <<| |>>
}
