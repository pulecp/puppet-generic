class gen_graphite {
  kservice { 'carbon-cache':
    package => 'graphite-carbon';
  }

  package { 'graphite-web':; }
}
