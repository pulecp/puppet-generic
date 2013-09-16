class gen_elasticsearch ($cluster_name='elasticsearch', $bind_address='0.0.0.0', $node_name=$hostname, $path_data='/srv/elasticsearch'){
  include gen_java::openjdk_7_jre

  kservice { 'elasticsearch':; }

  file {
    '/etc/elasticsearch/elasticsearch.yml':
      content => template('gen_elasticsearch/elasticsearch.yml'),
      require => Package['elasticsearch'],
      notify  => Exec['restart-elasticsearch'];
    $path_data:
      ensure  => directory,
      owner   => 'elasticsearch',
      group   => 'elasticsearch',
      mode    => 755,
      require => Package['elasticsearch'];
  }
}
