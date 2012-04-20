class gen_django {
  package { ["libapache2-mod-python","python-django"]:
    ensure => latest;
  }
}
