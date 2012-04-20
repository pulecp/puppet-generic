class gen_java::sun_java6_jdk {

  include gen_java::sun_java6_jre

  package { "sun-java6-jdk":
    responsefile => "/tmp/sunlicense.preseed",
    require => File["/tmp/sunlicense.preseed"];
  }
}

# Class: gen_java::sun_java6_jre_crypto_policy
#
# Action:
#  Install strong crypto libraries for java
#
class gen_java::sun_java6_jre_crypto_policy {
  file {
    "/usr/lib/jvm/java-6-sun/jre/lib/security/US_export_policy.jar":
      source  => "puppet:///modules/gen_java/jce/US_export_policy.jar",
      require => Package["sun-java6-jre"];
    "/usr/lib/jvm/java-6-sun/jre/lib/security/local_policy.jar":
      source  => "puppet:///modules/gen_java/jce/local_policy.jar",
      require => Package["sun-java6-jre"];
  }
}

class gen_java::sun_java6_jre {
  file { "/tmp/sunlicense.preseed":
    content => template("gen_java/preseed");
  }

  package { "sun-java6-jre":
    responsefile => "/tmp/sunlicense.preseed",
    require => File["/tmp/sunlicense.preseed"];
  }
}

class gen_java::oracle_java7_jdk {
  include gen_java::oracle_java7_jre

  package { "oracle-java7-jdk":; }
}

class gen_java::oracle_java7_jre {
  package { "oracle-java7-jre":; }
}

# Class: gen_java::oracle_java7_jre_crypto_policy
#
# Action:
#  Install strong crypto libraries for java
#
class gen_java::oracle_java7_jre_crypto_policy {
  file {
    "/usr/lib/jvm/java-7-oracle/jre/lib/security/US_export_policy.jar":
      source  => "puppet:///modules/gen_java/jce7/US_export_policy.jar",
      require => Package["oracle-java7-jre"];
    "/usr/lib/jvm/java-7-oracle/jre/lib/security/local_policy.jar":
      source  => "puppet:///modules/gen_java/jce7/local_policy.jar",
      require => Package["oracle-java7-jre"];
  }
}
