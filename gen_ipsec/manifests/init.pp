# Author: Kumina bv <support@kumina.nl>

# Class: gen_ipsec
#
# Actions:
#  Configure basic ipsec settings; needs at least one gen_ipsec::peer.
#
# Parameters:
#  listen
#    The IP address(es) that racoon listens on
#  ssl_path
#    The default path to ssl certificates
#
# Depends:
#  gen_puppet
#
class gen_ipsec ($listen=false, $ssl_path="/etc/ssl") {
  kpackage {
    ["ipsec-tools","racoon"]:;
  }

  service {
    "setkey":
      require   => Package["ipsec-tools"];
    "racoon":
      ensure    => running,
      hasstatus => false,
      pattern   => "/usr/sbin/racoon",
      require   => Package["racoon"];
  }

  $itc = "/etc/ipsec-tools.conf"
  
  concat { 
    $itc:
      mode    => 744,
      notify  => Service["setkey"],
      require => Package["ipsec-tools"];
  }

  concat::fragment { "ipsec-tools.conf_header":
    target => $itc,
    order  => 1,
    source => "gen_ipsec/ipsec-tools.conf_header";
  }

  kfile {
    "/etc/racoon/racoon.conf":
      ensure  => present,
      content => template("gen_ipsec/racoon.conf.erb"),
      notify  => Service["racoon"],
      require => Package["racoon"];
    "/etc/racoon/peers.d":
      ensure  => directory;
  }

}

# Define: gen_ipsec::peer
#
# Actions:
#  Configure an ipsec peer
#
# Parameters:
#  local_ip
#    Local endpoint of the ipsec tunnel
#  peer_ip
#    Remote endpoint of the ipsec tunnel
#  peer_asn1dn
#    Peer's ASN.1 DN (Everything after "Subject: " in output of openssl x509 -text)
#  local_cidr
#    (List of) local networks (e.g. ["10.1.2.0/24","10.1.4.0/23"])
#  remote_cidr
#    (List of) remote networks
#  cert
#    Path to certificate file (optional)
#  key
#    Path to private key file (optional)
#
# Depends:
#  gen_puppet
#
define gen_ipsec::peer ($local_ip, $peer_ip, $peer_asn1dn, $local_cidr, $remote_cidr, $cert="certs/${fqdn}.pem", $key="private/${fqdn}.key") {
  concat::fragment { "ipsec-tools.conf_fragment_$name":
    target  => "/etc/ipsec-tools.conf",
    order   => 10,
    content => template("gen_ipsec/ipsec-tools.conf_fragment.erb");
  }

  file { "/etc/racoon/peers.d/$name.conf":
    ensure  => present,
    content => template("gen_ipsec/racoon-peer.conf.erb"),
    require => [ Package["racoon"], File["/etc/racoon/peers.d"] ],
    notify  => Service["racoon"];
  }
}
