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
  kpackage { ["spamassassin","libmail-spf-perl", "libmail-dkim-perl"]:; }

  kfile { "/etc/default/spamassassin":
    source => "spamassassin/default/spamassassin";
  }
}
