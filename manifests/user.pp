define ssh::user(
    $uid,
    $gid,
    $comment,
    $ssh_key='',
    $ssh_keys={},
    $groups=undef,
    $shell='/bin/bash',
    $pwhash='',
    $password_min_age=undef,
    $password_max_age=undef,
    $expiry=undef,
    $username=$title,
    $managehome=true,
    $home='',
    $hosts=[],
    ) {

    if $hosts == [] or $hostname in $hosts {

        if $managehome == true {
            User <| title == $username |> { managehome => true }
            User <| title == $username |> { home => "/home/${username}" }
        }

        # custom home location
        if $home != '' {
            User <| title == $username |> { managehome => true }
        }

        # Create a usergroup
        group { $username:
            ensure  => present,
            gid     => $gid,
        }

        user { $username:
            ensure      => present,
            uid         => $uid,
            gid         => $gid,
            groups      => $groups,
            shell       => $shell,
            password_min_age  => $password_min_age,
            password_max_age  => $password_max_age,
            expiry      => $expiry,
            comment     => $comment,
            require     => [
                Group[$username]
            ],
        }

        # Set password if available
        if $pwhash != '' {
            User <| title == $username |> { password => $pwhash }
        }

        file { "/home/${username}":
            ensure  => directory,
            owner   => $username,
            group   => $username,
            mode    => '0700',
        }

        file { "/home/${username}/.ssh":
            ensure  => directory,
            owner   => $username,
            group   => $username,
            mode    => '0700',
        }

        file { "/home/$username/.ssh/authorized_keys":
            ensure  => present,
            owner   => $username,
            group   => $username,
            mode    => '0600',
            require => File["/home/${username}/.ssh"],
        }

        Ssh_authorized_key {
            require =>  File["/home/${username}/.ssh/authorized_keys"]
        }

        $ssh_key_defaults = {
            ensure  => present,
            user    => $username,
            type    => 'ssh-rsa'
        }

        if $ssh_key {
            ssh_authorized_key { $ssh_key['comment']:
                ensure  => present,
                user    => $username,
                type    => $ssh_key['type'],
                key     => $ssh_key['key'],
            }
        }

        if $ssh_keys {
            create_resources("ssh_authorized_key", $ssh_keys, $ssh_key_defaults)
        }
    }
}
