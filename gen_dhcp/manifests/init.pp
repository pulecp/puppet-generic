# Class: kbp_dhcp::server
#
# Actions:
#  Install a DHCP server.
#
# Depends:
#  gen_puppet
#
class gen_dhcp::server {
  kservice { 'isc-dhcp-server':;}

  concat { '/etc/dhcp/dhcpd.conf':; }

  concat::add_content { 'dhcpd defaults':
    target  => '/etc/dhcp/dhcpd.conf',
    content => template('gen_dhcp/dhcpd_default.conf');
  }
}

# Class: gen_dhcp::server::subnet
#
# Actions:
#  Configure a subnet for the DHCP server
#
# Parameters:
#  network_subnet:
#   The network-address of the subnet
#  network_netmask:
#   The netmask op the subnet
#  network_router:
#   The default gateway for the network
#  range:
#   An array with 2 elements, describing the range of addresses that the DHCP server hands out (or false for all)
#  name_servers:
#   and array with nameserver addresses pushed to the client
#  name_search:
#   An array with the seach domains for the clients
#  name_domain:
#   The domain for the clients
#
# Depends:
#  gen_dhcp::server
#
define gen_dhcp::server::subnet ($network_subnet, $network_netmask='255.255.255.0', $network_router, $range=false, $name_servers=['8.8.8.8','8.8.4.4'], $name_search=false, $name_domain=false) {
  concat::add_content { "Subnet ${name}":
    target  => '/etc/dhcp/dhcpd.conf',
    content => template('gen_dhcp/dhcpd_network.conf');
  }
}

# Class: gen_dhcp::server::host
#
# Actions:
#  Configure a host with a 'static' IP for the DHCP server
#
# Parameters:
#  host_address:
#   The IP address for the host
#  host_macaddress:
#   The Mac-Address of the host
#
# Depends:
#  gen_dhcp::server
#
define gen_dhcp::server::host ($host_address, $host_macaddress) {
  concat::add_content { "Host ${name}":
    target  => '/etc/dhcp/dhcpd.conf',
    content => template('gen_dhcp/dhcpd_host.conf');
  }
}
