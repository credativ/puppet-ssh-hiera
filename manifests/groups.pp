class ssh::groups (
    $manage,
    $groups
    ) {

    if $manage {
        create_resources(ssh::group, $groups)
    }
}

