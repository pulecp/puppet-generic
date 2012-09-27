# Author: Kumina bv <support@kumina.nl>

# Class: gen_ipsec
#
# Actions:
#  Configure basic ipsec settings; needs at least one gen_ipsec::peer.
#
# Parameters:
#  listen
#    The IP address(es) that racoon listens on (default all)
#  ssl_path
#    The default path to ssl certificates (default /etc/ssl)
#
# Depends:
#  gen_puppet
#
class gen_ipsec ($listen=false, $ssl_path="/etc/ssl") {
  kservice {
    "setkey":
      ensure    => "undef",
      hasstatus => false,
      package   => "ipsec-tools",
      pensure   => latest;
    "racoon":
      hasstatus => false,
      pattern   => "/usr/sbin/racoon",
      pensure   => latest;
  }

  concat {
    "/etc/ipsec-tools.conf":
      mode    => 744,
      notify  => Service["setkey"],
      require => Package["ipsec-tools"];
    "/etc/racoon/psk.txt":
      mode    => 600,
      force   => true,
      notify  => Service["racoon"],
      require => Package["racoon"];
  }

  concat::add_content { "ipsec-tools.conf_header":
    target  => "/etc/ipsec-tools.conf",
    order   => "01",
    content => template("gen_ipsec/ipsec-tools.conf_header");
  }

  file {
    "/etc/racoon/racoon.conf":
      content => template("gen_ipsec/racoon.conf.erb"),
      notify  => Service["racoon"],
      require => Package["racoon"];
    "/etc/racoon/peers.d":
      ensure  => directory,
      require => Package["racoon"];
  }
}

# Define: gen_ipsec::peer
#
# Actions:
#  Configure an ipsec peer
#  A key and certificate need to be created in advance.
#
# Parameters:
#  local_ip
#    Local endpoint of the ipsec tunnel
#  peer_ip
#    Remote endpoint of the ipsec tunnel
#  encap
#    Encapsulation mode. Must be "tunnel" (default) or "transport"
#  exchange_mode
#    Phase 1 exchange mode (optional, default "main")
#  proposal_check
#    racoon's proposal check (see racoon(8)) (optional, default "obey")
#  peer_asn1dn
#    Peer's ASN.1 DN (Everything after "Subject: " in output of openssl x509 -text)
#  localnet
#    For tunnel mode: (list of) local networks (e.g. ["10.1.2.0/24","10.1.4.0/23"])
#  remotenet
#    For tunnel mode: (list of) remote networks
#  authmethod
#    Phase 1 authentication method. Can be "rsasig" (default) or "psk"/"pre_shared_key"
#  psk
#    In case of authmethod=psk: the pre-shared key to be used
#  cert
#    Path to certificate file (optional)
#  key
#    Path to private key file (optional)
#  cafile
#    Path to CA certificate (optional)
#  phase1_enc
#    Phase 1 encryption algorithm (optional)
#  phase1_hash
#    Phase 1 hash algorithm (optional)
#  phase1_dh
#    Phase 1 Diffie-Hellman group (optional)
#  phase1_lifetime_time (optional)
#    Phase 1 lifetime (time); can be sec, min or hour (e.g. "12 hour")
#  phase2_dh
#    Phase 2 Diffie-Hellman group (optional)
#  phase2_enc
#    Phase 2 encryption algorithm (optional)
#  phase2_auth
#    Phase 2 authentication method (optional)
#  phase2_lifetime_time (optional)
#    Phase 2 lifetime (time); can be sec, min or hour (e.g. "12 hour")
#  phase2_lifetime_byte (optional)
#    Phase 2 lifetime (byte); e.g. "4096 MB"
#  policy_level
#    Policy level (search for "level" in setkey(8)) (optional)
#
# Depends:
#  gen_puppet
#
define gen_ipsec::peer ($local_ip, $peer_ip, $encap="tunnel", $exchange_mode="main", $proposal_check=false, $peer_asn1dn=false, $localnet=false, $remotenet=false, $authmethod="rsasig", $psk=false, $cert="certs/${fqdn}.pem", $key="private/${fqdn}.key", $cafile="cacert.pem", $phase1_enc="aes 256", $phase1_hash="sha1", $phase1_dh="5", $phase1_lifetime_time=false, $phase2_dh="5", $phase2_enc="aes 256", $phase2_auth="hmac_sha1", $phase2_lifetime_time=false, $phase2_lifetime_byte=false, $policy_level="unique") {
  $resname = "Gen_ipsec::peer[${name}]"
  $my_authmethod = $authmethod ? {
    /(rsasig|pre_shared_key)/ => $authmethod,
    "psk"                     => "pre_shared_key",
    default                   => fail("${resname}: authmethod should be \"rsasig\", \"pre_shared_key\" or \"psk\"."),
  }

  if ! ($encap  in ["tunnel","transport"]) {
    fail("${resname}: encap must be \"tunnel\" or \"transport\"")
  }

  if $encap == "tunnel" {
    if ! $localnet { fail("${resname}: encap_mode is \"tunnel\" and localnet not set!") }
    if ! $remotenet { fail("${resname}: encap_mode is \"tunnel\" and remotenet not set!") }
    $my_localnet = $localnet
    $my_remotenet = $remotenet
  }
  else {
    $my_localnet = $local_ip
    $my_remotenet = $peer_ip
  }

  if $my_authmethod == "pre_shared_key" {
    if $psk {
      concat::add_content { "psk_fragment_$name":
        target  => "/etc/racoon/psk.txt",
        content => "$peer_ip $psk\n";
      }
    }
    else {
      fail("${resname}: authmethod set to psk, but no pre-shared key given!")
    }
  }

  if $my_authmethod == "rsasig" {
    if ! $peer_asn1dn {
      fail("${resname}: authmethod set to rsasig, but no peer_asn1dn given!")
    }
  }

  concat::add_content { "ipsec-tools.conf_fragment_$name":
    target  => "/etc/ipsec-tools.conf",
    content => template("gen_ipsec/ipsec-tools.conf_fragment.erb");
  }

  file { "/etc/racoon/peers.d/$name.conf":
    content => template("gen_ipsec/racoon-peer.conf.erb"),
    require => [ Package["racoon"], File["/etc/racoon/peers.d"] ],
    notify  => Service["racoon"];
  }
}
