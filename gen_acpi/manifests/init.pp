# Author: Kumina bv <support@kumina.nl>

# Class: gen_acpi
#
# Actions:
#  Sets up acpi
#
# Depends:
#  gen_puppet
#
class gen_acpi {
  kservice { "acpid":
    package => "acpi-support-base";
  }
}
