class ssh::known_hosts (
    $manage,
    $manage_hostkey
    ) {

    if $manage_hostkey {
        $known_hosts = ssh_keygen( { "request" => 'known_hosts', dir => 'ssh/hostkeys'}         )

        # if we are managing hostkeys, we are using its known_hosts file
        file { '/etc/ssh/ssh_known_hosts':
            mode    => '0644',
            content => $known_hosts
        }

    } else {
        # storeconfig based implementation is in another class, because otherwise
        # the server is complaining loud if storeconfig is not enabled
        class { 'ssh::known_hosts::storeconfig': }
    }
    
}
