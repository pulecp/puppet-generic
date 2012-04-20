# Author: Kumina bv <support@kumina.nl>

# Class: spamassassin
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class spamassassin {
  package { ["spamassassin","libmail-spf-perl", "libmail-dkim-perl"]:; }

  file { "/etc/default/spamassassin":
    content => template("spamassassin/spamassassin");
  }
}
