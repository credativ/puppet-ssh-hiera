class ssh::users (
    $manage,
    $users,
    $users_default,
    ) {

    if $manage {
        create_resources(ssh::user, $users, $users_default)
    }
}

