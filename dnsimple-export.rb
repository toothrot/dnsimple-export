require 'dnsimple'

DOMAIN_TO_EXPORT = ARGV[0]
MAIN_NS = "lady.ns.cloudfront.com"
SOA_EMAIL_AS_FQDN = "dave.dave.io"
NS_RECORDS = ["matt.ns.cloudflare.com", "lady.ns.cloudflare.com"]
DEFAULT_TTL = "3600"

config = YAML.load(open("auth.config").read)
DNSimple::Client.username = config['username']
DNSimple::Client.password = config['password']

records_in = DNSimple::Record.all(DOMAIN_TO_EXPORT)

header = <<-EOFS
	@    #{DEFAULT_TTL}   IN      SOA     #{MAIN_NS}. #{SOA_EMAIL_AS_FQDN}. (
	                        #{Time.now.strftime("%Y%m%d%H")}      ; serial YYYYMMDDHH
	                        #{DEFAULT_TTL}            ; refresh, seconds
	                        #{DEFAULT_TTL}            ; retry, seconds
	                        #{DEFAULT_TTL}000         ; expire, seconds
	                        86400 )         ; minimum, seconds
EOFS

records_out = []

NS_RECORDS.each do |ns_hostname|
  records_out.push "#{DOMAIN_TO_EXPORT}. #{DEFAULT_TTL} IN NS #{ns_hostname}."
end

records_in.each do |record|
  record_line = ""
  if (record.name.blank?)
    record_line += (DOMAIN_TO_EXPORT + ".")
  else
    record_line += record.name
  end
  record_line += " "
  record_line += record.ttl.to_s
  record_line += " IN "
  record_line += record.record_type
  record_line += " "
  if record.record_type == "TXT"
    record_line += ('"' + record.content + '"')
  else
    record_line += record.content
  end
  records_out.push record_line
end

puts header
puts
records_out.each do |record_line|
  puts record_line
end

  