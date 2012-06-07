class gen_django {
  package { ["python-django"]:
    ensure => latest;
  }
}
