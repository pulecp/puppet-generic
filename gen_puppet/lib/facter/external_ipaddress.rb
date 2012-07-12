begin
  # Do we have a fact called ec2_public_ipv4?
  if Facter.value(:ec2_public_ipv4).nil?
    # Get the route to 8.8.8.8, get the ip address mentioned after 'src', this is the IP that has the source address (and is most likely the external IP).
    ip = %x{/bin/ip route get 8.8.8.8}.each_line.grep(/src/)[0].split.last
  else
    ip = Facter.value(:ec2_public_ipv4)
  end
  # Add the fact if the found IP is not a local loopback address or an RFC 1918 address.
  if ip.scan(/(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/).empty?
    Facter.add("external_ipaddress") do
      setcode do
        ip
      end
    end
  end
rescue
# do nothing
end
