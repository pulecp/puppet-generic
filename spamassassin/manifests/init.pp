class spamassassin {
	kpackage { ["spamassassin","libmail-spf-perl", "libmail-dkim-perl"]:; }

	kfile { "/etc/default/spamassassin":
		source => "spamassassin/default/spamassassin";
	}
}
