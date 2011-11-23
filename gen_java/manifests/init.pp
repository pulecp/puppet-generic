class gen_java::sun_java6_jdk {

  include gen_java::sun_java6_jre

  kpackage { "sun-java6-jdk":
    responsefile => "/tmp/sunlicense.preseed",
    require => File['/tmp/sunlicense.preseed'];
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
