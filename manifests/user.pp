define ssh::user {
    $username = $name['name']
    $gecos = $name['gecos']
    $additional_groups = $name['additional_groups']
    $shell = $name['shell']
    $uid = $name['uid']
    $gid = $name['gid']

    # Create a usergroup
    group { $username:
        ensure => present,
        gid => $gid,
    }

    user { $username:
        ensure => present,
        uid => $uid,
        gid => $gid,
        groups => $additional_groups,
        shell => "/bin/bash",
        comment => $gecos,
        managehome => yes,
        require => [
            Group[$additional_groups],
            Group[$username]
        ],

    }

    # Set shell if available
    if "shell" in $name {
        User <| title == "$username" |> { shell => $name["shell"] }
    }

    # Set password if available
    if "pwhash" in $name {
        User <| title == "$username" |> { password => $name["pwhash"] }
    }

    file { "/home/${username}/.ssh":
        ensure => directory,
        owner => $username,
        group => $username,
        mode => '0700',
    }

    if "ssh_key" in $name {
        $ssh_key = $name['ssh_key']

        ssh_authorized_key { $ssh_key["comment"]:
             ensure => present,
             user => $username,
             type => $ssh_key["type"],
             key => $ssh_key["key"],
        }
    }
}
