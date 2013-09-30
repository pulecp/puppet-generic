#
# Class: gen_elasticsearch
#
# Actions: Set up elasticsearch and configure it.
#
# Parameters:
#  cluster_name: The name of the cluster
#  bind_address: The IP address to bind on
#  node_name: The name of the node in the cluster
#  path_data: The path to the elasticsearch data
#
# Depends:
#  gen_puppet
#
class gen_elasticsearch ($cluster_name='elasticsearch', $bind_address='0.0.0.0', $node_name=$hostname, $path_data='/srv/elasticsearch', $extra_opts=false){
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

#
# Class: gen_elasticsearch::plugin
#
# Actions: Install a plugin for elasticsearch
#
# Parameters:
#  name: The 'path' to the plugin (used to call plugin) (e.g. mobz/elasticsearch-head for the head plugin)
#  install_name: The name the plugin will have on-disk
#
# Depends:
#  gen_puppet
#
define gen_elasticsearch::plugin ($install_name) {
  exec { "Elasticsearch plugin ${name}":
    command => "/usr/share/elasticsearch/bin/plugin --install ${name}",
    creates => "/usr/share/elasticsearch/plugins/${install_name}",
    require => Package['elasticsearch'];
  }
}
