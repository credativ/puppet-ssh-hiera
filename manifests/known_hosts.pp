class ssh::known_hosts {
    @@sshkey { $hostname: 
        type => rsa,
        key => $sshrsakey
    }

    Sshkey <<| |>>
}
