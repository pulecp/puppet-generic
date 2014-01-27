#
# Class: gen_elasticsearch
#
# Actions: Set up elasticsearch and configure it.
#
# Parameters:
#  min_nodes: discovery.zen.minimum_master_nodes setting
#  cluster_name: The name of the cluster
#  path_data: The path to the elasticsearch data
#  extra_opts: a hash of extra elasticsearch options
#  nodes: an array of IP addresses of the es nodes in this cluster, use this if you don't want to use multicast
#  heapsize: the setting for ES_HEAP_SIZE
#
# Depends:
#  gen_puppet
#
class gen_elasticsearch ($min_nodes, $cluster_name='elasticsearch', $path_data='/srv/elasticsearch', $extra_opts=false, $nodes=false, $heapsize=false, $overwrite_config=true){
  include gen_java::openjdk_7_jre

  kservice { 'elasticsearch':; }

  file {
    '/etc/elasticsearch/elasticsearch.yml':
      content => template('gen_elasticsearch/elasticsearch.yml'),
      replace => $overwrite_config,
      require => Package['elasticsearch'],
      notify  => Exec['restart-elasticsearch'];
    '/etc/default/elasticsearch':
      content => template('gen_elasticsearch/elasticsearch.default'),
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
#  install_name: The name the plugin will have on-disk (i.e. head for the head plugin)
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
