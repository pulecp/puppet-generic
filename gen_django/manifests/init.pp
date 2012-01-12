class gen_django {
  kpackage { ["libapache2-mod-python","python-django"]:
    ensure => latest;
  }
}
