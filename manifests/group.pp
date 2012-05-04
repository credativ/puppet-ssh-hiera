define ssh::group ($groupname=$title, $gid) {
    group { $groupname:
        ensure => present,
        gid => $gid
    }

}
