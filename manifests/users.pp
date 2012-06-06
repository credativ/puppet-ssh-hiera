class ssh::users (
    $manage,
    $users
    ) {

    if $manage {
        create_resources(ssh::user, $users)
    }
}

