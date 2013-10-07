#
# Class: gen_redis::server
#
# Actions: Install and set up redis-server.
#
# Parameters:
#  bind_address: The address to bind to
#  datadir: The directory where the redis data is stored
#  memory_limit: The maximum amount of memory to use in bytes. Defaults to false, to disable this.
#  appendonly: Whether to enable the appendonly log or not. Defaults to false.
#
# Depends:
#  gen_puppet
#
class gen_redis ($bind_address='127.0.0.1', $datadir='/var/lib/redis', $memory_limit=false, $appendonly=false) {
  kservice { 'redis-server':; }

  file {
    '/etc/redis/redis.conf':
      content => template('gen_redis/redis.conf'),
      require => Package['redis-server'],
      notify  => Exec['restart-redis-server'];
    $datadir:
      ensure  => directory,
      owner   => 'redis',
      group   => 'redis',
      require => Package['redis-server'];
  }
}
