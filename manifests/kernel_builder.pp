class gpfs::kernel_builder  {

  package{["imake", "kernel-devel", "kernel-headers"]:
    ensure  => present,
  }

  package{ "gpfs.gpl":
    ensure  => latest,
    require => Package["imake", "kernel-devel", "kernel-headers"],
  }
}
