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
#
class gen_pacemaker ($customtag="pacemaker_${environment}"){
  package { "pacemaker":; }

  # These exported kfiles contain the fragments for /etc/heartbeat/cib.cfg
  Ekfile <<| tag == $customtag |>>

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

# Define: gen_pacemaker::cib_cfg
#
# A define that is wrapped by all define that need to put fragments into cib.cfg, this define exports all the configuration
#
# Parameters:
#  $content
#    The content of the fragment (duh)
#  $linebreak
#    Should the fragment be terminated by a newline?
#  $customtag
#    The tag for this fragment, this is needed when you have multiple clusters in a single environment
#
define gen_pacemaker::cib_cfg ($content, $linebreak=true, $customtag) {
  concat::add_content { "${name}":
    target     => "/etc/heartbeat/cib.cfg",
    contenttag => $customtag,
    exported   => true,
    linebreak  => $linebreak,
    content    => $content;
  }
}

# Define: gen_pacemaker::primitive
#
# Read http://www.clusterlabs.org/doc/en-US/Pacemaker/1.0/html/Pacemaker_Explained/index.html to understand pacemaker
# Parameters:
#  $provider
#    The provider for this primitive
#  $location
#    The location(node) where this resource should reside
#  $location_score
#    The weight for this location
#  $location_name
#    The name of the location resource(not mandatory)
#  $start_timeout
#    How long to wait for the resource to start, before it has failed
#  $monitor_interval
#    How long inbetween checks of the resource?
#  $monitor_timeout
#    How long until the resource has failed?
#  $stop_timeout
#    WHen it takes this long to stop a resource, consider it failed
#  $params
#    Any other parameters required by the resource
#  $group
#    The name of the group this resource belongs to (optional)
#  $customtag
#    Set this when you have multiple clusters in 1 environment
define gen_pacemaker::primitive ($provider, $location, $location_score="50", $location_name=false, $start_timeout="20s", $monitor_interval="10s", $monitor_timeout="20s", $stop_timeout="20s", $params=false, $group=false, $customtag="pacemaker_${environment}") {
  gen_pacemaker::cib_cfg { "primitive_${name}":
    content   => template("gen_pacemaker/primitive.erb"),
    customtag => $customtag;
  }

  if $group {
    gen_pacemaker::cib_cfg { "group_${group}_2_${name}":
      content   => " ${name}",
      customtag => $customtag,
      linebreak => false,
      require   => Gen_pacemaker::Group[$group];
    }
  }

  if $location {
    $loc_name = $location_name ? {
      false   => "prefer-${name}",
      default => $location_name,
    }
    gen_pacemaker::location { "${loc_name}":
      primitive => "${name}",
      score     => $location_score,
      resnode   => $location,
      customtag => $customtag;
    }
  }
}

#
# Define: gen_pacemaker::master_slave
#
# Parameters:
#  $primitive:
#    The primitive in this master/slave group
#  $meta:
#    The metadata associated with this group
#  $customtag:
#    Set this to the appropriate cluster
define gen_pacemaker::master_slave ($primitive, $meta, $customtag="pacemaker_${environment}") {
  gen_pacemaker::cib_cfg { "ms_${name}":
    content   => template("gen_pacemaker/ms.erb"),
    customtag => $customtag,
  }
}

#
# Define: gen_pacemaker::clone
#
# Parameters:
#  $primitive:
#    The primitive that should be cloned. Can be a group as well.
#  $meta:
#    The metadata associated with this clone.
#  $customtag:
#    Set this to the appropriate cluster
define gen_pacemaker::clone ($primitive, $meta, $customtag="pacemaker_${environment}") {
  gen_pacemaker::cib_cfg { "ms_${name}":
    content   => template("gen_pacemaker/clone.erb"),
    customtag => $customtag,
  }
}

#
# Define: gen_pacemaker::location
#
# http://www.clusterlabs.org/doc/en-US/Pacemaker/1.0/html/Pacemaker_Explained/ch-constraints.html
#
# Parameters:
#  $primitive:
#    For which primitive is this location
#  $score:
#    The stickyness of the resource
#  $resnode
#    The node on which this resource must stick
#  $customtag
#    Set this to the appropriate cluster
#
define gen_pacemaker::location ($primitive, $score, $resnode, $customtag="pacemaker_${environment}") {
  gen_pacemaker::cib_cfg { "location_${name}":
    content   => template("gen_pacemaker/location.erb"),
    customtag => $customtag;
  }
}

#
# Define: gen_pacemaker::colocation
#
# Parameters:
#  $resource1, $resource2:
#    The resources to co-locate
#  $score:
#    How badly do you want these resources on the same node?
#  $customtag:
#    Set this to the appropriate cluster
#
define gen_pacemaker::colocation ($resource_1, $resource_2, $score="inf", $customtag="pacemaker_${environment}") {
  gen_pacemaker::cib_cfg { "colocation_${name}":
    content   => template("gen_pacemaker/colocation.erb"),
    customtag => $customtag;
  }
}

#
# Define: gen_pacemaker::order
#
# Parameters:
#  $resource1, $resource2:
#    The resources to order. The order is 2 after 1.
#  $score:
#    How badly do you want to start resource2 after resource1
#  $customtag:
#    Set this to the appropriate cluster
#
define gen_pacemaker::order ($resource_1, $resource_2, $score="inf", $customtag="pacemaker_${environment}") {
  gen_pacemaker::cib_cfg { "order_${name}":
    content   => template("gen_pacemaker/order.erb"),
    customtag => $customtag;
  }
}

#
# Define: gen_pacemaker::group
#
# Use this to define a group, resources are added to it by using the $group parameter from gen_pacemaker::primitive
#
# Parameters:
#  $customtag:
#    Set this to the appropriate cluster
#
define gen_pacemaker::group ($customtag="pacemaker_${environment}"){
  gen_pacemaker::cib_cfg {
    "group_${name}_1":
      linebreak => false,
      customtag => $customtag,
      content   => "group ${name}";
    "group_${name}_3":
      customtag => $customtag,
      content   => "\n";
  }
}
