# Author: Kumina bv <support@kumina.nl>

# Class: gen_base::abswrap
#
# Actions:
#  Install abswrap
#
# Depends:
#  gen_puppet
#
class gen_base::abswrap {
  kpackage { "abswrap":
    ensure => latest;
  }
}

# Class: gen_base::ant
#
# Actions:
#  Install ant
#
# Depends:
#  gen_puppet
#
class gen_base::ant {
  kpackage { "ant":
    ensure => latest;
  }
}

# Class: gen_base::apache2_mpm_prefork
#
# Actions:
#  Install apache2-mpm-prefork
#
# Depends:
#  gen_puppet
#
class gen_base::apache2_mpm_prefork {
  kpackage { "apache2-mpm-prefork":
    ensure => latest;
  }
}

# Class: gen_base::apache2_mpm_worker
#
# Actions:
#  Install apache2-mpm-worker
#
# Depends:
#  gen_puppet
#
class gen_base::apache2_mpm_worker {
  kpackage { "apache2-mpm-worker":
    ensure => latest;
  }
}

# Class: gen_base::libaugeas-ruby
#
# Actions:
#  Install augeas and it's lenses
#
# Depends:
#  gen_puppet
#
class gen_base::augeas {
  kpackage { ["libaugeas-ruby", "augeas-lenses","libaugeas-ruby1.8","libaugeas0","augeas-tools"]:
    ensure => latest,
    notify => Exec["reload-puppet"];
  }
}

# Class: gen_base::backup-scripts
#
# Actions:
#  Install backup-scripts
#
# Depends:
#  gen_puppet
#
class gen_base::backup-scripts {
  kpackage { "backup-scripts":
    ensure => latest;
  }
}

# Class: gen_base::base-files
#
# Actions:
#  Install base-files
#
# Depends:
#  gen_puppet
#
class gen_base::base-files {
  kpackage { "base-files":
    ensure => latest;
  }
}

# Class: gen_base::bridge-utils
#
# Actions:
#  Install bridge-utils
#
# Depends:
#  gen_puppet
#
class gen_base::bridge-utils {
  kpackage { "bridge-utils":
    ensure => latest;
  }
}

# Class: gen_base::bsdtar
#
# Actions:
#  Install bsdtar
#
# Depends:
#  gen_puppet
#
class gen_base::bsdtar {
  kpackage { "bsdtar":
    ensure => latest;
  }
}

# Class: gen_base::bzip2
#
# Actions:
#  Install bzip2
#
# Depends:
#  gen_puppet
#
class gen_base::bzip2 {
  kpackage { "bzip2":
    ensure => latest;
  }
}

# Class: gen_base::curl
#
# Actions:
#  Install curl
#
# Depends:
#  gen_puppet
#
class gen_base::curl {
  include gen_base::libcurl3
  kpackage { "curl":
    ensure => latest;
  }
}

# Class: gen_base::dnsutils
#
# Actions:
#  Install dnsutils
#
# Depends:
#  gen_puppet
#
class gen_base::dnsutils {
  kpackage { "dnsutils":
    ensure => latest;
  }
}

# Class: gen_base::dpkg
#
# Actions:
#  Install dpkg
#
# Depends:
#  gen_puppet
#
class gen_base::dpkg {
  kpackage { "dpkg":
    ensure => latest;
  }
}

# Class: gen_base::echoping
#
# Actions:
#  Install echoping
#
# Depends:
#  gen_puppet
#
class gen_base::echoping {
  kpackage { "echoping":
    ensure => latest;
  }
}

# Class: gen_base::elinks
#
# Actions:
#  Install elinks
#
# Depends:
#  gen_puppet
#
class gen_base::elinks {
  include gen_base::libgnutls26
  kpackage { "elinks":
    ensure => latest;
  }
}

# Class: gen_base::facter
#
# Actions:
#  Install facter
#
# Depends:
#  gen_puppet
#
class gen_base::facter {
  kpackage { "facter":
    notify => Exec["reload-puppet"];
  }
}

# Class: gen_base::ia32-libs
#
# Actions:
#  Install ia32-libs
#
# Depends:
#  gen_puppet
#
class gen_base::ia32-libs {
  kpackage { "ia32-libs":
    ensure => latest;
  }
}

# Class: gen_base::ifenslave-2_6
#
# Actions:
#  Install ifenslave-2_6
#
# Depends:
#  gen_puppet
#
class gen_base::ifenslave-2_6 {
  kpackage { "ifenslave-2.6":
    ensure => latest;
  }
}

# Class: gen_base::imagemagick
#
# Actions:
#  Install imagemagick
#
# Depends:
#  gen_puppet
#
class gen_base::imagemagick {
  kpackage { "imagemagick":
    ensure => latest;
  }
}

# Class: gen_base::javascript-common
#
# Actions:
#  Install javascript-common
#
# Depends:
#  gen_puppet
#
class gen_base::javascript-common {
  kpackage { "javascript-common":
    ensure => latest;
  }
}

# Class: gen_base::jmxquery
#
# Actions:
#  Install jmxquery
#
# Depends:
#  gen_puppet
#
class gen_base::jmxquery {
  kpackage { "jmxquery":
    ensure => latest;
  }
}

# Class: gen_base::libcurl3
#
# Actions:
#  Install libcurl3
#
# Depends:
#  gen_puppet
#
class gen_base::libcurl3 {
  kpackage { "libcurl3":
    ensure => latest;
  }
}

# Class: gen_base::libcurl3_gnutls
#
# Actions:
#  Install libcurl3-gnutls
#
# Depends:
#  gen_puppet
#
class gen_base::libcurl3_gnutls {
  kpackage { "libcurl3-gnutls":
    ensure => latest;
  }
}

# Class: gen_base::libgnutls26
#
# Actions:
#  Install libgnutls26
#
# Depends:
#  gen_puppet
#
class gen_base::libgnutls26 {
  kpackage { "libgnutls26":
    ensure => latest;
  }
}

# Class: gen_base::libgssapi-krb5-2
#
# Actions:
#  Install libgssapi-krb5-2
#
# Depends:
#  gen_puppet
#
class gen_base::libgssapi-krb5-2 {
  kpackage { "libgssapi-krb5-2":
    ensure => latest;
  }
}

# Class: gen_base::libk5crypto3
#
# Actions:
#  Install libk5crypto3
#
# Depends:
#  gen_puppet
#
class gen_base::libk5crypto3 {
  kpackage { "libk5crypto3":
    ensure => latest;
  }
}

# Class: gen_base::libkrb5-3
#
# Actions:
#  Install libkrb5-3
#
# Depends:
#  gen_puppet
#
class gen_base::libkrb5-3 {
  kpackage { "libkrb5-3":
    ensure => latest;
  }
}

# Class: gen_base::libkrb5support0
#
# Actions:
#  Install libkrb5support0
#
# Depends:
#  gen_puppet
#
class gen_base::libkrb5support0 {
  kpackage { "libkrb5support0":
    ensure => latest;
  }
}

# Class: gen_base::libactiverecord_ruby18
#
# Actions:
#  Install libactiverecord-ruby1.8
#
# Depends:
#  gen_puppet
#
class gen_base::libactiverecord_ruby18 {
  kpackage { "libactiverecord-ruby1.8":
    ensure => latest;
  }
}

# Class: gen_base::libapache2-mod-auth-mysql
#
# Actions:
#  Install libapache2-mod-auth-mysql
#
# Depends:
#  gen_puppet
#
class gen_base::libapache2-mod-auth-mysql {
  kpackage { "libapache2-mod-auth-mysql":
    ensure => latest,
    notify => Exec["reload-apache2"];
  }
}

# Class: gen_base::libapache2-mod-fcgid
#
# Actions:
#  Install libapache2-mod-fcgid
#
# Depends:
#  gen_puppet
#
class gen_base::libapache2-mod-fcgid {
  kpackage { "libapache2-mod-fcgid":
    ensure => latest,
    notify => Exec["reload-apache2"];
  }
}

# Class: gen_base::libapache2-mod-passenger
#
# Actions:
#  Install libapache2-mod-passenger
#
# Depends:
#  gen_puppet
#
class gen_base::libapache2-mod-passenger {
  kpackage { "libapache2-mod-passenger":
    ensure => latest;
  }
}

# Class: gen_base::libapache2-mod-perl2
#
# Actions:
#  Install libapache2-mod-perl2
#
# Depends:
#  gen_puppet
#
class gen_base::libapache2-mod-perl2 {
  kpackage { "libapache2-mod-perl2":
    ensure => latest;
  }
}

# Class: gen_base::libapache2-mod-php5
#
# Actions:
#  Install libapache2-mod-php5
#
# Depends:
#  gen_puppet
#
class gen_base::libapache2-mod-php5 {
  kpackage { "libapache2-mod-php5":
    ensure => latest;
  }
}

# Class: gen_base::libapache2-mod-wsgi
#
# Actions:
#  Install libapache2-mod-wsgi
#
# Depends:
#  gen_puppet
#
class gen_base::libapache2-mod-wsgi {
  kpackage { "libapache2-mod-wsgi":
    ensure => latest;
  }
}

# Class: gen_base::libapr1
#
# Actions:
#  Install libapr1
#
# Depends:
#  gen_puppet
#
class gen_base::libapr1 {
  kpackage { "libapr1":
    ensure => latest;
  }
}

# Class: gen_base::libcommons-logging-java
#
# Actions:
#  Install libcommons-logging-java
#
# Depends:
#  gen_puppet
#
class gen_base::libcommons-logging-java {
  kpackage { "libcommons-logging-java":
    ensure => latest;
  }
}

# Class: gen_base::libcups2
#
# Actions:
#  Install libcups2
#
# Depends:
#  gen_puppet
#
class gen_base::libcups2 {
  kpackage { "libcups2":
    ensure => latest;
  }
}

# Class: gen_base::libcupsimage2
#
# Actions:
#  Install libcupsimage2
#
# Depends:
#  gen_puppet
#
class gen_base::libcupsimage2 {
  kpackage { "libcupsimage2":
    ensure => latest;
  }
}

# Class: gen_base::libdate-calc-perl
#
# Actions:
#  Install libdate-calc-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libdate-calc-perl {
  kpackage { "libdate-calc-perl":
    ensure => latest;
  }
}

# Class: gen_base::libdate-manip-perl
#
# Actions:
#  Install libdate-manip-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libdate-manip-perl {
  kpackage { "libdate-manip-perl":
    ensure => latest;
  }
}

# Class: gen_base::libdbi-perl
#
# Actions:
#  Install libdbi-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libdbi-perl {
  kpackage { "libdbi-perl":
    ensure => latest;
  }
}

# Class: gen_base::libfreetype6
#
# Actions:
#  Install libfreetype6
#
# Depends:
#  gen_puppet
#
class gen_base::libfreetype6 {
  kpackage { "libfreetype6":
    ensure => latest;
  }
}

# Class: gen_base::libio-socket-inet6-perl
#
# Actions:
#  Install libio-socket-inet6-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libio-socket-inet6-perl {
  kpackage { "libio-socket-inet6-perl":
    ensure => latest;
  }
}

# Class: gen_base::libmozjs2d
#
# Actions:
#  Install libmozjs2d
#
# Depends:
#  gen_puppet
#
class gen_base::libmozjs2d {
  kpackage { "libmozjs2d":
    ensure => latest;
  }
}

# Class: gen_base::libmysql-ruby
#
# Actions:
#  Install libmysql-ruby
#
# Depends:
#  gen_puppet
#
class gen_base::libmysql-ruby {
  kpackage { "libmysql-ruby":
    ensure => latest;
  }
}

# Class: gen_base::libnet_dns_perl
#
# Actions:
#  Install libnet-dns-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libnet_dns_perl {
  kpackage { "libnet-dns-perl":
    ensure => latest;
  }
}

# Class: gen_base::libnet-ip-perl
#
# Actions:
#  Install libnet-ip-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libnet-ip-perl {
  kpackage { "libnet-ip-perl":
    ensure => latest;
  }
}

# Class: gen_base::libnet-ping-external-perl
#
# Actions:
#  Install libnet-ping-external-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libnet-ping-external-perl {
  kpackage { "libnet-ping-external-perl":
    ensure => latest;
  }
}

# Class: gen_base::liblog4j1_2-java
#
# Actions:
#  Install liblog4j1.2-java
#
# Depends:
#  gen_puppet
#
class gen_base::liblog4j1_2-java {
  kpackage { "liblog4j1.2-java":
    ensure => latest;
  }
}

# Class: gen_base::libmailtools-perl
#
# Actions:
#  Install libmailtools-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libmailtools-perl {
  kpackage { "libmailtools-perl":
    ensure => latest;
  }
}

# Class: gen_base::libpam-modules
#
# Actions:
#  Install libpam-modules
#
# Depends:
#  gen_puppet
#
class gen_base::libpam-modules {
  kpackage { "libpam-modules":
    ensure => latest;
  }
}

# Class: gen_base::libpam-runtime
#
# Actions:
#  Install libpam-runtime
#
# Depends:
#  gen_puppet
#
class gen_base::libpam-runtime {
  kpackage { "libpam-runtime":
    ensure => latest;
  }
}

# Class: gen_base::libpam0g
#
# Actions:
#  Install libpam0g
#
# Depends:
#  gen_puppet
#
class gen_base::libpam0g {
  kpackage { "libpam0g":
    ensure => latest;
  }
}

# Class: gen_base::libparallel-forkmanager-perl
#
# Actions:
#  Install libparallel-forkmanager-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libparallel-forkmanager-perl {
  kpackage { "libparallel-forkmanager-perl":
    ensure => latest;
  }
}

# Class: gen_base::libpng12_0
#
# Actions:
#  Install libpng12-0
#
# Depends:
#  gen_puppet
#
class gen_base::libpng12_0 {
  kpackage { "libpng12-0":
    ensure => latest;
  }
}

# Class: gen_base::libpq5
#
# Actions:
#  Install libpq5
#
# Depends:
#  gen_puppet
#
class gen_base::libpq5 {
  kpackage { "libpq5":
    ensure => latest;
  }
}

# Class: gen_base::libreadline5-dev
#
# Actions:
#  Install libreadline5-dev
#
# Depends:
#  gen_puppet
#
class gen_base::libreadline5-dev {
  kpackage { "libreadline5-dev":
    ensure => latest;
  }
}

# Class: gen_base::libsnmp-perl
#
# Actions:
#  Install libsnmp-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libsnmp-perl {
  kpackage { "libsnmp-perl":
    ensure => latest;
  }
}

# Class: gen_base::libsocket6-perl
#
# Actions:
#  Install libsocket6-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libsocket6-perl {
  kpackage { "libsocket6-perl":
    ensure => latest;
  }
}

# Class: gen_base::libspreadsheet-parseexcel-perl
#
# Actions:
#  Install libspreadsheet-parseexcel-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libspreadsheet-parseexcel-perl {
  kpackage { "libspreadsheet-parseexcel-perl":
    ensure => latest;
  }
}

# Class: gen_base::libssl-dev
#
# Actions:
#  Install libssl-dev
#
# Depends:
#  gen_puppet
#
class gen_base::libssl-dev {
  kpackage { "libssl-dev":
    ensure => latest;
  }
}

# Class: gen_base::libstomp_ruby
#
# Actions:
#  Install libstomp-ruby
#
# Depends:
#  gen_puppet
#
class gen_base::libstomp_ruby {
  kpackage { "libstomp-ruby":
    ensure => latest;
  }
}

# Class: gen_base::libt1-5
#
# Actions:
#  Install libt1-5
#
# Depends:
#  gen_puppet
#
class gen_base::libt1-5 {
  kpackage { "libt1-5":
    ensure => latest;
  }
}

# Class: gen_base::libtime-modules-perl
#
# Actions:
#  Install libtime-modules-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libtime-modules-perl {
  kpackage { "libtime-modules-perl":
    ensure => latest;
  }
}

# Class: gen_base::libwww-perl
#
# Actions:
#  Install libwww-perl
#
# Depends:
#  gen_puppet
#
class gen_base::libwww-perl {
  kpackage { "libwww-perl":
    ensure => latest;
  }
}

# Class: gen_base::libxenstore3_0
#
# Actions:
#  Install libxenstore3.0
#
# Depends:
#  gen_puppet
#
class gen_base::libxenstore3_0 {
  kpackage { "libxenstore3.0":
    ensure => latest;
  }
}

# Class: gen_base::libxml2
#
# Actions:
#  Install libxml2
#
# Depends:
#  gen_puppet
#
class gen_base::libxml2 {
  kpackage { "libxml2":
    ensure => latest;
  }
}

# Class: gen_base::libxml2_utils
#
# Actions:
#  Install libxml2-utils
#
# Depends:
#  gen_puppet
#
class gen_base::libxml2_utils {
  kpackage { "libxml2-utils":
    ensure => latest;
  }
}

# Class: gen_base::linux-base
#
# Actions:
#  Install linux-base
#
# Depends:
#  gen_puppet
#
class gen_base::linux-base {
  kpackage { "linux-base":
    ensure => latest;
  }
}

# Class: gen_base::linux-image
#
# Actions:
#  Make sure the latest image is installed
#
# Parameters:
#  version
#    The version we need to install the latest package of.
#
# Depends:
#  gen_puppet
#
class gen_base::linux-image ($version) {
  kpackage { "linux-image-${version}":
    ensure => latest;
  }

  # Also install the normal lenny kernel if we're not running the backports kernel already
  if ($lsbdistcodename == "lenny") and ($kernelrelease != "2.6.26-2-amd64") {
    kpackage { "linux-image-2.6.26-2-amd64":
      ensure => latest;
    }
  }
}

# Class: gen_base::mailgraph
#
# Actions:
#  Install mailgraph
#
# Depends:
#  gen_puppet
#
class gen_base::mailgraph {
  kpackage { "mailgraph":
    ensure => latest;
  }
}

# Class: gen_base::mc
#
# Actions:
#  Install mc
#
# Depends:
#  gen_puppet
#
class gen_base::mc {
  kpackage { "mc":
    ensure => latest;
  }
}

# Class: gen_base::module_init_tools
#
# Actions:
#  Install module-init-tools
#
# Depends:
#  gen_puppet
#
class gen_base::module_init_tools {
  kpackage { "module-init-tools":
    ensure => latest;
  }
}

# Class: gen_base::ttf_mscorefonts_installer
#
# Actions:
#  Install ttf-mscorefonts-installer
#
# Depends:
#  gen_puppet
#
class gen_base::ttf_mscorefonts_installer {
  kpackage { "ttf-mscorefonts-installer":
    ensure => latest;
  }
}

# Class: gen_base::mysql_client
#
# Actions:
#  Install mysql-client
#
# Depends:
#  gen_puppet
#
class gen_base::mysql_client {
  kpackage { "mysql-client":
    ensure => latest;
  }
}

# Class: gen_base::munin-libvirt-plugins
#
# Actions:
#  Install munin-libvirt-plugins
#
# Depends:
#  gen_puppet
#
class gen_base::munin-libvirt-plugins {
  include gen_base::python-libvirt
  kpackage { "munin-libvirt-plugins":
    ensure => latest;
  }
}

# Class: gen_base::nagios-nrpe-plugin
#
# Actions:
#  Install nagios-nrpe-plugin
#
# Depends:
#  gen_puppet
#
class gen_base::nagios-nrpe-plugin {
  kpackage { "nagios-nrpe-plugin":
    ensure => latest;
  }
}

# Class: gen_base::nagios-plugins-standard
#
# Actions:
#  Install nagios-plugins-standard
#
# Depends:
#  gen_puppet
#
class gen_base::nagios-plugins-standard {
  include gen_base::libxml2
  kpackage { "nagios-plugins-standard":
    ensure => latest;
  }
}

# Class: gen_base::netpbm
#
# Actions:
#  Install netpbm
#
# Depends:
#  gen_puppet
#
class gen_base::netpbm {
  kpackage { "netpbm":
    ensure => latest;
  }
}

# Class: gen_base::nscd
#
# Actions:
#  Install nscd
#
# Depends:
#  gen_puppet
#
class gen_base::nscd {
  kpackage { "nscd":
    ensure => latest;
  }
}

# Class: gen_base::openoffice.org_base
#
# Actions:
#  Install openoffice.org-base
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_base {
  kpackage { "openoffice.org-base":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_calc
#
# Actions:
#  Install openoffice.org-calc
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_calc {
  kpackage { "openoffice.org-calc":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_emailmerge
#
# Actions:
#  Install openoffice.org-emailmerge
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_emailmerge {
  kpackage { "openoffice.org-emailmerge":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_filter-binfilter
#
# Actions:
#  Install openoffice.org-filter-binfilter
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_filter-binfilter {
  kpackage { "openoffice.org-filter-binfilter":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_filter-mobiledev
#
# Actions:
#  Install openoffice.org-filter-mobiledev
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_filter-mobiledev {
  kpackage { "openoffice.org-filter-mobiledev":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_impress
#
# Actions:
#  Install openoffice.org-impress
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_impress {
  kpackage { "openoffice.org-impress":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_math
#
# Actions:
#  Install openoffice.org-math
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_math {
  kpackage { "openoffice.org-math":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_officebean
#
# Actions:
#  Install openoffice.org-officebean
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_officebean {
  kpackage { "openoffice.org-officebean":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_report-builder-bin
#
# Actions:
#  Install openoffice.org-report-builder-bin
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_report-builder-bin {
  kpackage { "openoffice.org-report-builder-bin":
    ensure => installed;
  }
}

# Class: gen_base::openoffice.org_writer
#
# Actions:
#  Install openoffice.org-writer
#
# Depends:
#  gen_puppet
#
class gen_base::openoffice.org_writer {
  kpackage { "openoffice.org-writer":
    ensure => installed;
  }
}

# Class: gen_base::openjdk-6-jre
#
# Actions:
#  Install openjdk-6-jre
#
# Depends:
#  gen_puppet
#
class gen_base::openjdk-6-jre {
  kpackage { "openjdk-6-jre":
    ensure => installed;
  }
}

# Class: gen_base::perl
#
# Actions:
#  Install perl
#
# Depends:
#  gen_puppet
#
class gen_base::perl {
  kpackage { "perl":
    ensure => latest;
  }
}

# Class: gen_base::php_apc
#
# Actions:
#  Install php-apc
#
# Depends:
#  gen_puppet
#
class gen_base::php_apc {
  kpackage { "php-apc":
    ensure => latest;
  }
}

# Class: gen_base::php_pear
#
# Actions:
#  Install php-pear
#
# Depends:
#  gen_puppet
#
class gen_base::php_pear {
  kpackage { "php-pear":
    ensure => latest;
  }
}

# Class: gen_base::php5_cgi
#
# Actions:
#  Install php5-cgi
#
# Depends:
#  gen_puppet
#
class gen_base::php5_cgi {
  kpackage { "php5-cgi":
    ensure => latest;
  }
}

# Class: gen_base::php5_cli
#
# Actions:
#  Install php5-cli
#
# Depends:
#  gen_puppet
#
class gen_base::php5_cli {
  kpackage { "php5-cli":
    ensure => latest;
  }
}

# Class: gen_base::php5_common
#
# Actions:
#  Install php5-common
#
# Depends:
#  gen_puppet
#
class gen_base::php5_common {
  kpackage { "php5-common":
    ensure => latest;
  }
}

# Class: gen_base::php5_curl
#
# Actions:
#  Install php5-curl
#
# Depends:
#  gen_puppet
#
class gen_base::php5_curl {
  kpackage { "php5-curl":
    ensure => latest;
  }
}

# Class: gen_base::php5_gd
#
# Actions:
#  Install php5-gd
#
# Depends:
#  gen_puppet
#
class gen_base::php5_gd {
  include gen_base::libpng12_0
  kpackage { "php5-gd":
    ensure => latest;
  }
}

# Class: gen_base::php5_imagick
#
# Actions:
#  Install php5-imagick
#
# Depends:
#  gen_puppet
#
class gen_base::php5_imagick {
  include gen_base::imagemagick
  kpackage { "php5-imagick":
    ensure => latest;
  }
}

# Class: gen_base::php5_ldap
#
# Actions:
#  Install php5-ldap
#
# Depends:
#  gen_puppet
#
class gen_base::php5_ldap {
  kpackage { "php5-ldap":
    ensure => latest;
  }
}

# Class: gen_base::php5_mcrypt
#
# Actions:
#  Install php5-mcrypt
#
# Depends:
#  gen_puppet
#
class gen_base::php5_mcrypt {
  kpackage { "php5-mcrypt":
    ensure => latest;
  }
}

# Class: gen_base::php5_mysql
#
# Actions:
#  Install php5-mysql
#
# Depends:
#  gen_puppet
#
class gen_base::php5_mysql {
  kpackage { "php5-mysql":
    ensure => latest;
  }
}

# Class: gen_base::php5_xdebug
#
# Actions:
#  Install php5-xdebug
#
# Depends:
#  gen_puppet
#
class gen_base::php5_xdebug {
  kpackage { "php5-xdebug":
    ensure => latest;
  }
}

# Class: gen_base::python-argparse
#
# Actions:
#  Install python-argparse
#
# Depends:
#  gen_puppet
#
class gen_base::python-argparse {
  kpackage { "python-argparse":
    ensure => latest;
  }
}

# Class: gen_base::python-dnspython
#
# Actions:
#  Install python-dnspython
#
# Depends:
#  gen_puppet
#
class gen_base::python-dnspython {
  kpackage { "python-dnspython":
    ensure => latest;
  }
}

# Class: gen_base::python-ipaddr
#
# Actions:
#  Install python-ipaddr
#
# Depends:
#  gen_puppet
#
class gen_base::python-ipaddr {
  kpackage { "python-ipaddr":
    ensure => latest;
  }
}

# Class: gen_base::python-libvirt
#
# Actions:
#  Install python-libvirt
#
# Depends:
#  gen_puppet
#
class gen_base::python-libvirt {
  include gen_base::libxenstore3_0
  include gen_base::python_libxml2
  kpackage { "python-libvirt":
    ensure => latest;
  }
}

# Class: gen_base::python_libxml2
#
# Actions:
#  Install python-libxml2
#
# Depends:
#  gen_puppet
#
class gen_base::python_libxml2 {
  include gen_base::libxml2
  kpackage { "python-libxml2":
    ensure => latest;
  }
}

# Class: gen_base::python-mysqldb
#
# Actions:
#  Install python-mysqldb
#
# Depends:
#  gen_puppet
#
class gen_base::python-mysqldb {
  kpackage { "python-mysqldb":
    ensure => latest;
  }
}

# Class: gen_base::python_pycurl
#
# Actions:
#  Install python-pycurl
#
# Depends:
#  gen_puppet
#
class gen_base::python_pycurl {
  include gen_base::libcurl3_gnutls
  kpackage { "python-pycurl":
    ensure => latest;
  }
}

# Class: gen_base::rails
#
# Actions:
#  Install rails
#
# Depends:
#  gen_puppet
#
class gen_base::rails {
  kpackage { "rails":
    ensure => latest;
  }
}

# Class: gen_base::realpath
#
# Actions:
#  Install realpath
#
# Depends:
#  gen_puppet
#
class gen_base::realpath {
  kpackage { "realpath":
    ensure => latest;
  }
}

# Class: gen_base::rsync
#
# Actions:
#  Install rsync
#
# Depends:
#  gen_puppet
#
class gen_base::rsync {
  kpackage { "rsync":
    ensure => latest;
  }
}

# Class: gen_base::ruby_stomp
#
# Actions:
#  Install ruby-stomp 1.1.9 from the Kumina repository
#
# Depends:
#  gen_puppet
#
class gen_base::ruby_stomp {
  kpackage { "ruby-stomp":
    ensure => latest;
  }
}

# Class: gen_base::smbclient
#
# Actions:
#  Install smbclient
#
# Depends:
#  gen_puppet
#
class gen_base::smbclient {
  kpackage { "smbclient":
    ensure => latest;
  }
}

# Class: gen_base::subversion
#
# Actions:
#  Install subversion
#
# Depends:
#  gen_puppet
#
class gen_base::subversion {
  kpackage { "subversion":
    ensure => latest;
  }
}

# Class: gen_base::sysstat
#
# Actions:
#  Install sysstat
#
# Depends:
#  gen_puppet
#
class gen_base::sysstat {
  kpackage { "sysstat":
    ensure => latest;
  }
}

# Class: gen_base::telnet_ssl
#
# Actions:
#  Install telnet-ssl
#
# Depends:
#  gen_puppet
#
class gen_base::telnet_ssl {
  kpackage { "telnet-ssl":
    ensure => latest;
  }
}

# Class: gen_base::unoconv
#
# Actions:
#  Install unoconv
#
# Depends:
#  gen_puppet
#
class gen_base::unoconv {
  kpackage { "unoconv":
    ensure => latest;
  }
}

# Class: gen_base::unzip
#
# Actions:
#  Install unzip
#
# Depends:
#  gen_puppet
#
class gen_base::unzip {
  kpackage { "unzip":
    ensure => latest;
  }
}

# Class: gen_base::vim
#
# Actions:
#  Install vim
#
# Depends:
#  gen_puppet
#
class gen_base::vim {
  kpackage { "vim":
    ensure => latest;
  }
}

# Class: gen_base::vim-addon-manager
#
# Actions:
#  Install vim-addon-manager
#
# Depends:
#  gen_puppet
#
class gen_base::vim-addon-manager {
  kpackage { "vim-addon-manager":
    ensure => latest;
  }
}

# Class: gen_base::vlan
#
# Actions:
#  Install vlan
#
# Depends:
#  gen_puppet
#
class gen_base::vlan {
  kpackage { "vlan":
    ensure => latest;
  }
}

# Class: gen_base::wget
#
# Actions:
#  Install wget
#
# Depends:
#  gen_puppet
#
class gen_base::wget {
  kpackage { "wget":
    ensure => latest;
  }
}

# Class: gen_base::wondershaper
#
# Actions:
#  Install wondershaper
#
# Depends:
#  gen_puppet
#
class gen_base::wondershaper {
  kpackage { "wondershaper":
    ensure => latest;
  }
}

# Class: gen_base::xvfb
#
# Actions:
#  Install xvfb
#
# Depends:
#  gen_puppet
#
class gen_base::xvfb {
  kpackage { "xvfb":
    ensure => latest;
  }
}
