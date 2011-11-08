# Author: Kumina bv <support@kumina.nl>

# Class: gen_cassandra
#
# Actions:
#  Setup Cassandra from an external repository.
#
# Parameters:
#  branch
#    The branch to use, defaults to 07x.
#
# Depends:
#  gen_apt
#  gen_puppet
#
class gen_cassandra ($branch = "07x") {
  gen_apt::key { "8D77295D":
    source => "gen_cassandra/8D77295D",
  }

  gen_apt::source { "cassandra":
    comment      => "Cassandra repository.",
    sourcetype   => "deb",
    uri          => "http://www.apache.org/dist/cassandra/debian",
    distribution => $branch,
    components   => "main",
    key          => "8D77295D",
  }

  kpackage { "cassandra":
    ensure => installed,
  }
}
