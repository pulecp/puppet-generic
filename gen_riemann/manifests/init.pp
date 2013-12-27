class gen_riemann::server {
  kservice { 'riemann':; }

  gen_apt::preference { 'riemann':
    repo => 'kumina-wheezy';
  }
}
