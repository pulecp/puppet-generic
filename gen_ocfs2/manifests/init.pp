# Class: apache
#
# Actions:
#  Set up ocfs2, the cluster config will not be generated
#
# Depends:
#  gen_puppet
#
class gen_ocfs2 {
  kservice { "o2cb":
    package => "ocfs2-tools",
    require => File["/etc/default/o2cb"];
  }

  file {
    "/etc/ocfs2":
      ensure  => directory;
    "/etc/default/o2cb":
      content => template("gen_ocfs2/o2cb");
  }
}
