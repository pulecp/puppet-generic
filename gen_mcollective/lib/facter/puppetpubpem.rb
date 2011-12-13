# puppetpubpem.rb

file = "/var/lib/puppet/ssl/public_keys/#{Facter.value(:fqdn)}.pem"
if FileTest.file?(file)
	Facter.add("puppetpubpem") do
		setcode do
			File.open(file) { |f|
				f.read.gsub!(/\n/, ";")
			}
		end
	end
end
