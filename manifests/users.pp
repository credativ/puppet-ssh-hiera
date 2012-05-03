class ssh::users {
    # Get groups and users from hiera
    $groups = hiera('ssh_groups')
    $users = hiera('ssh_users')

    # Create groups and users defined in hiera
    ssh::group { $groups: }
    ssh::user { $users: }
}

