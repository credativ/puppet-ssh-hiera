class ssh::users (
    $manage,
    $users,
    $default,
    ) {

    if $manage {
        create_resources(ssh::user, $users, $default)
    }
}

