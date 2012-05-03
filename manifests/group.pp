define ssh::group () {
    $groupname = $name['name']
    $gid = $name['gid']

    group { $groupname:
        ensure => present,
        gid => $gid
    }

}
