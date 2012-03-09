# Author: Kumina bv <support@kumina.nl>

# Class: gen_mcollective::server
#
# Actions:
#  Set up an mcollective server using Puppet certs for security
#
# Depends:
#  gen_puppet
#
class gen_mcollective::server {
  include gen_mcollective::common

  kservice { "mcollective":
    require => File["/etc/default/mcollective"];
  }

  concat { "/etc/mcollective/server.cfg":
    mode    => 600,
    require => Package["mcollective"],
    notify  => Service["mcollective"];
  }

  concat::add_content { "0 server.cfg base":
    content => template("gen_mcollective/server.cfg_base"),
    target  => "/etc/mcollective/server.cfg";
  }

  Concat::Add_content <<| target == "/etc/mcollective/server.cfg" |>>

  file { "/etc/default/mcollective":
    content => "RUN=yes",
    notify  => Service["mcollective"];
  }

  File <<| tag == "mcollective_client_pubkey" |>>
}

# Class: gen_mcollective::client
#
# Actions:
#  Set up an mcollective client using Puppet certs for security
#
# Depends:
#  gen_puppet
#
class gen_mcollective::client {
  include gen_mcollective::common

  kpackage { "mcollective-client":; }

  concat { "/etc/mcollective/client.cfg":
    mode    => 600,
    require => Package["mcollective-client"];
  }

  concat::add_content { "0 client.cfg base":
    content => template("gen_mcollective/client.cfg_base"),
    target  => "/etc/mcollective/client.cfg";
  }

  Concat::Add_content <<| target == "/etc/mcollective/client.cfg" |>>

  @@file { "/etc/mcollective/ssl/clients/${fqdn}.pem":
    content => regsubst($puppetpubpem,";","\n","G"),
    tag     => "mcollective_client_pubkey",
    require => Package["mcollective"],
    notify  => Service["mcollective"];
  }
}

# Class: gen_mcollective::common
#
# Actions:
#  Install common MCollective packages and fix a bug in aes_security (this fix prevents letting servers initiate requests)
#
# Depends:
#  gen_puppet
#
class gen_mcollective::common {
  kpackage { "mcollective-common":; }

  file { "/usr/share/mcollective/plugins/mcollective/security/aes_security.rb":
    content => template("gen_mcollective/aes_security.rb"),
    require => Package["mcollective-common"],
    notify  => Service["mcollective"];
  }
}
