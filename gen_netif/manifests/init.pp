# Author: Kumina bv <support@kumina.nl>

# Define: gen_netif::alias
#
# Actions:
#  Setup network interface aliases
#
# Parameters:
#  name
#    description; ends up as comment in aliases file
#  iface
#    Network interface, e.g. "eth0"
#  ip
#    IP address. Can be IPv4 or IPv6 address and can include netmask in CIDR notation
#    e.g. 10.1.2.3 or 10.2.4.8/29 or fd00:1234::b00b:babe/64
#
# Depends:
#  gen_puppet
#
define gen_netif::alias($iface, $ip) {
  $cidr = $ip ? {
    # loosely matches IPv4 addresses
    /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/ => "${ip}/32",
    # matches IPv4 and IPv6 addresses (in my tests IPv4 addresses always get eaten by the above regex first)
    /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])(.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])){3}))|:)))(%.+)?\s*$/ => "${ip}/128",
    default            => $ip,
  }

  file {
    '/etc/network/if-up.d/up-aliases':
      content => template('gen_netif/up-aliases'),
      mode    => 755;
    '/etc/network/if-down.d/down-aliases':
      ensure  => link,
      target  => '../if-up.d/up-aliases';
    '/etc/network/refresh-aliases.sh':
      content => template('gen_netif/refresh-aliases.sh'),
      mode    => 755;
  }

  exec { "refresh-netif-aliases-${iface}":
    command     => "/etc/network/refresh-aliases.sh ${iface}",
    refreshonly => true;
  }

  concat { '/etc/network/aliases':
    force   => true,
    notify  => Exec["refresh-netif-aliases-${iface}"];
  }

  concat::add_content { "netif-alias ${cidr} on ${iface}":
    target  => '/etc/network/aliases',
    content => "${iface} ${cidr}     # ${name}\n",
    notify  => Exec["refresh-netif-aliases-${iface}"];
  }
}
