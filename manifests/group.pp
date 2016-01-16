define ssh::group ($gid, $groupname=$title) {
    group { $groupname:
        ensure => present,
        gid    => $gid
    }

}
