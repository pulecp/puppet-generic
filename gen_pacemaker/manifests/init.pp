# Author: Kumina bv <support@kumina.nl>

# Copyright (C) 2010 Kumina bv
# This works is published under the Creative Commons Attribution-Share
# Alike 3.0 Unported license - http://creativecommons.org/licenses/by-sa/3.0/
# See LICENSE for the full legal text.

# Class: gen_pacemaker
#
# Actions:
#  Installs pacemaker and imports the configuration fragments.
#
# Depends:
#  gen_puppet
class gen_pacemaker {
  package { "pacemaker":; }

  concat { "/etc/heartbeat/cib.cfg":
    require => Package["heartbeat"],
    notify  => Exec["reload cib.cfg"];
  }

  # This actually updates the configuration. But we only need to do this if
  # the file changes.
  exec { "reload cib.cfg":
    command     => "/usr/sbin/crm configure load update /etc/heartbeat/cib.cfg",
    refreshonly => true,
    require     => [File["/etc/heartbeat/cib.cfg"],Package["pacemaker"],Service["heartbeat"]];
  }

  # This piece of configuration is always the same for us.
  concat::add_content { "properties_${name}":
    target  => "/etc/heartbeat/cib.cfg",
    content => "property \$id=\"cib-bootstrap-options\" \\
      cluster-infrastructure=\"Heartbeat\" \\
      stonith-enabled=\"false\" \\
      expected-quorum-votes=\"2\" \\
      no-quorum-policy=\"ignore\"";
  }
}

# Define: gen_pacemaker::primitive
#
# Read http://www.clusterlabs.org/doc/en-US/Pacemaker/1.0/html/Pacemaker_Explained/index.html to understand pacemaker
# Parameters:
#  provider:         The provider for this primitive
#  location:         The location(node) where this resource should reside
#  location_score:   The weight for this location
#  location_name:    The name of the location resource(not mandatory)
#  start_timeout:    How long to wait for the resource to start, before it has failed
#  monitor_interval: How long inbetween checks of the resource?
#  monitor_timeout:  How long until the resource has failed?
#  stop_timeout:     When it takes this long to stop a resource, consider it failed
#  params:           Any other parameters required by the resource
#  group:            The name of the group this resource belongs to (optional)
define gen_pacemaker::primitive ($provider, $location=false, $location_score='50', $location_name=false, $start_timeout='20s', $monitor_interval='10s', $monitor_timeout='20s', $stop_timeout='20s', $params=false, $group=false) {
  concat::add_content { "primitive_${name}":
    target  => '/etc/heartbeat/cib.cfg',
    content => template('gen_pacemaker/primitive.erb');
  }

  if $group {
    concat::add_content { "group_${group}_2_${name}":
      target    => '/etc/heartbeat/cib.cfg',
      content   => " ${name}",
      linebreak => false,
      require   => Gen_pacemaker::Group[$group];
    }
  }

  if $location {
    $loc_name = $location_name ? {
      false   => "prefer-${name}",
      default => $location_name,
    }
    gen_pacemaker::location { $loc_name:
      primitive => $name,
      score     => $location_score,
      resnode   => $location;
    }
  }
}

# Define: gen_pacemaker::master_slave
#
# Parameters:
#  primitive: The primitive in this master/slave group
#  meta:      The metadata associated with this group
define gen_pacemaker::master_slave ($primitive, $meta) {
  concat::add_content { "ms_${name}":
    target  => '/etc/heartbeat/cib.cfg',
    content => template('gen_pacemaker/ms.erb');
  }
}

# Define: gen_pacemaker::location
#
# http://www.clusterlabs.org/doc/en-US/Pacemaker/1.0/html/Pacemaker_Explained/ch-constraints.html
#
# Parameters:
#  primitive: For which primitive is this location
#  score:     The stickyness of the resource
#  resnode:   The node on which this resource must stick
define gen_pacemaker::location ($primitive, $score, $resnode) {
  concat::add_content { "location_${name}":
    target  => '/etc/heartbeat/cib.cfg',
    content => template('gen_pacemaker/location.erb');
  }
}

# Define: gen_pacemaker::colocation
#
# Parameters:
#  resource1, $resource2: The resources to co-locate
#  score:                 How badly do you want these resources on the same node?
define gen_pacemaker::colocation ($resource_1, $resource_2, $score='inf') {
  concat::add_content { "colocation_${name}":
    target  => '/etc/heartbeat/cib.cfg',
    content => template("gen_pacemaker/colocation.erb");
  }
}

# Define: gen_pacemaker::order
#
# Parameters:
#  resource1, $resource2: The resources to order. The order is 2 after 1.
#  score:                 How badly do you want to start resource2 after resource1
define gen_pacemaker::order ($resource_1, $resource_2, $score='inf') {
  concat::add_content { "order_${name}":
    target  => '/etc/heartbeat/cib.cfg',
    content => template("gen_pacemaker/order.erb");
  }
}

# Define: gen_pacemaker::group
#
# Use this to define a group, resources are added to it by using the $group parameter from gen_pacemaker::primitive
define gen_pacemaker::group {
  concat::add_content {
    "group_${name}_1":
      target    => '/etc/heartbeat/cib.cfg',
      linebreak => false,
      content   => "group ${name}";
    "group_${name}_3":
      target    => '/etc/heartbeat/cib.cfg',
      content   => "\n";
  }
}
