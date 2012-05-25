define puppet-ssh-hiera::group (
  $gid,
  $groupname = $title
) {

  group { $groupname:
    ensure => present,
    gid    => $gid,
  }
}
