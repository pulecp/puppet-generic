class gen_gearman {
  kservice { 'gearman-job-server':
    package => 'gearman';
  }
}
