# We do not setup twiki, since there's no Debian package, this only installs the dependencies
class gen_twiki {
  include gen_base::perl
  include gen_base::libalgorithm_diff_perl
  include gen_base::liberror_perl
  include gen_base::libdigest_sha1_perl
  include gen_base::liblocale_maketext_lexicon_perl
  include gen_base::libcgi_session_perl
  include gen_base::liburi_perl
  include gen_base::libhtml_parser_perl
}
