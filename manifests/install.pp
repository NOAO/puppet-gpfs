class gpfs::install( $gpfs_version = '3.5.0' ) {
  # For at least GPFS 3.4 & 3.5, only the 3.x.0-0 package contains the file
  # /usr/lpp/mmfs/lib/liblum.so
  #
  # testing for the existance of that file seems to be the only way to tell if
  # the X.Y.0-0 package was installed before the 3.x.0-y update that obseletes
  # the earlier package.
  #
  # If gpfs.base is installed but /usr/lpp/mmfs/lib/liblum.so exist, we need to
  # actually remove gpfs.base since yum will not let us install 3.x.0-0 on top
  # of 3.x.0-(y>0). eg,:
  #
  # [root@foo01 ~]# rpm -qa gpfs.base
  # gpfs.base-3.5.0-4.x86_64
  # [root@foo01 ~]# yum install gpfs.base-3.5.0-0
  # Loaded plugins: priorities, security, upgrade-helper
  # 98 packages excluded due to repository priority protections
  # Setting up Install Process
  # Package matching gpfs.base-3.5.0-0.x86_64 already installed. Checking for
  # update.
  # Nothing to do

  $yum_install = 'yum install -y -e0 --disableexcludes=main'

  # remove gpfs.base if it looks like the 3.x.0-0 package wasn't prevously
  # installed, ie, we have an ordering problem likely caused by rpm/yum update
  # bypassing the 3.x.0-0 packages
#  exec { "yum erase -y -e0 gpfs.base-${gpfs_version}":
#    unless  => 'test ! -e /usr/lpp/mmfs/lib/liblum.so',
#    before  => Exec["gpfs.base-${gpfs_version}-0"],
#  }

  # the gpfs 3.x.0-0 base RPM has to be installed first and then later upgraded
  # to the 3.x.0-y patch level
  # we're doing a double exec in hopes that we'll converge in a single run
  # instead of waiting for a package resource to update the package later
  exec { "${yum_install} gpfs.base-${gpfs_version}-0":
    alias  => "gpfs.base-${gpfs_version}-0",
    path   => ['/bin', '/usr/bin'],
    unless => "rpm -q gpfs.base-${gpfs_version}",
    # we need to test for gpfs.base-<version> so we catch the case where we are
    # upgrading to a newer 3.Y.0 release
#    creates => '/usr/lpp/mmfs/lib/liblum.so',
  } ->
  exec { "${yum_install} gpfs.base-${gpfs_version}":
    alias  => "gpfs.base-${gpfs_version}",
    path   => ['/bin', '/usr/bin'],
    onlyif => "rpm -q gpfs.base-${gpfs_version}-0",
  }

  # install the correct gpfs gpl'd kernel glue for our running kernel.  Note
  # that these are not provided by IBM and need to be hand built for each
  # kernel release.

  # puppet will report that install this package fails... even though it doesn't
  # https://projects.puppetlabs.com/issues/10445
  #package{"gpfs.gplbin-$kernelrelease":
  #  ensure  => present,
  #  require => Package['gpfs.base'],
  #}

  exec { "${yum_install} gpfs.gplbin-${::kernelrelease}-${gpfs_version}":
    path    => ['/bin', '/usr/bin'],
    unless  => "rpm -q gpfs.gplbin-${::kernelrelease}-${gpfs_version}",
    require => Exec["gpfs.base-${gpfs_version}"],
  }

  # gpfs.docs & gpfs.msg.en_US don't require any special handling but the yum
  # provider doesn't work with --disableexcludes
  #
  # this proposed PR should be part of puppet 4.0.0
  # https://github.com/puppetlabs/puppet/pull/3336
  exec { "${yum_install} gpfs.docs":
    path   => ['/bin', '/usr/bin'],
    unless => 'rpm -q gpfs.docs',
  }

  exec { "${yum_install} gpfs.msg.en_US":
    path   => ['/bin', '/usr/bin'],
    unless => 'rpm -q gpfs.msg.en_US',
  }

  # add /usr/lpp/mmfs/bin to the default PATH
  file { '/etc/profile.d/gpfs.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/gpfs/gpfs.sh',
    require => Exec["gpfs.base-${gpfs_version}-0"],
  }
}
