class gen_graphite {
  kservice { 'graphite-carbon':; }

  package { 'graphite-web':; }
}
