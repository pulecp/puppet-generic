# Author: Kumina bv <support@kumina.nl>

# Class: gen_acpi
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class gen_acpi {
	kpackage { "acpi-support-base":; }

	kservice { "acpid":
		require => Kpackage["acpi-support-base"];
	}
}
