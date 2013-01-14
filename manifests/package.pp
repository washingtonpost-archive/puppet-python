class python::package {
  anchor { 'python::package::begin': }

  case $operatingsystem {
    # centos,fedora,rhel: {
    #   class { 'python::package::redhat':
    #     require => Anchor['python::package::begin'],
    #     before  => Anchor['python::package::end'],
    #   }
    # }
    debian,ubuntu: {
      class { 'python::package::debian':
        require => Anchor['python::package::begin'],
        before  => Anchor['python::package::end'],
      }
    }
    # opensuse,suse: {
    #   class { 'python::package::suse':
    #     require => Anchor['python::package::begin'],
    #     before  => Anchor['python::package::end'],
    #   }
    # }
    anchor { 'python::package::end': }

  }
}
