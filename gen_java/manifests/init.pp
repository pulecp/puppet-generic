class gen_java::sun_java6_jdk {

  include gen_java::sun_java6_jre

  kpackage { "sun-java6-jdk":
    responsefile => "/tmp/sunlicense.preseed",
    require => File['/tmp/sunlicense.preseed'];
  }
}

# Class: gen_java::sun_java6_jre_crypto_policy
#
# Action:
#  Install strong crypto libraries for java
#
class gen_java::sun_java6_jre_crypto_policy {
  kfile {
    "/usr/lib/jvm/java-6-sun/jre/lib/security/US_export_policy.jar":
      source  => "gen_java/jce/US_export_policy.jar",
      require => Package["sun-java6-jre"];
    "/usr/lib/jvm/java-6-sun/jre/lib/security/local_policy.jar":
      source => "gen_java/jce/local_policy.jar",
      require => Package["sun-java6-jre"];
  }
}

class gen_java::sun_java6_jre {

  kfile { '/tmp/sunlicense.preseed':
    source => 'gen_java/preseed';
  }

  kpackage { "sun-java6-jre":
    responsefile => "/tmp/sunlicense.preseed",
    require => File['/tmp/sunlicense.preseed'];
  }
}
