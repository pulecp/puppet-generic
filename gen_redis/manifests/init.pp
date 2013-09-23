#
# Class: gen_redis::server
#
# Actions: Install and set up redis-server.
#
# Parameters:
#  bind_address: The address to bind to
#  datadir: The directory where the redis data is stored
#
# Depends:
#  gen_puppet
#
class gen_redis ($bind_address='127.0.0.1', $datadir='/var/lib/redis') {
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
