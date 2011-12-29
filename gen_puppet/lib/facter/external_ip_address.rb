def add_fact(code)
  Facter.add("external_ip_address") { setcode { code } }
end

# Do we have a fact called ec2_public_ipv4?
add_fact(Facter.value(:ec2_public_ipv4)) if ! Facter.value(:ec2_public_ipv4).nil?

begin
  # Get the route to 8.8.8.8, get the ip address mentioned after 'src', this is the IP that has the source address (and is most likely the external IP).
  ip = %x{/bin/ip route get 8.8.8.8}.grep(/src/)[0].split.last
  # Add the fact if the found IP is not a local loopback address or an RFC 1918 address.
  add_fact(ip) if ip.grep(/(^127\.0\.0\.1)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/).empty?
rescue
# do nothing
end
