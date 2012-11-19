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
    content => template("gen_cassandra/8D77295D"),
  }

  # for the 10x branch
  gen_apt::key { "2B5C1B00":
    content => template("gen_cassandra/2B5C1B00"),
  }

  gen_apt::source { "cassandra":
    comment      => "Cassandra repository.",
    sourcetype   => "deb",
    uri          => "http://www.apache.org/dist/cassandra/debian",
    distribution => $branch,
    components   => "main",
    key          => $branch ? {
      "07x" => "8D77295D",
      "10x" => "2B5C1B00",
      "11x" => "2B5C1B00",
    };
  }

  package { "cassandra":
    ensure => installed,
  }
}
