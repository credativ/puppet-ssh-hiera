class ssh::users {
    # Get groups and users from hiera
    $groups = hiera('ssh_groups')
    $users = hiera('ssh_users')

    # Create resources for users and groups as defined in hiera
    create_resources(ssh::group, $groups)
    create_resources(ssh::user, $users)

}

