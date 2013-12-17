class gen_graphite {
  kservice { 'carbon-cache':
    package => 'graphite-carbon';
  }
}

class gen_graphite::graphite_web {
  package { 'graphite-web':; }
}
