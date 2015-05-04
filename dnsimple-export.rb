require 'rubygems'
require 'bundler/setup'
require 'dnsimple'
require 'dotenv'

Dotenv.load(File.join(ENV["HOME"], '.dnsimple-export'), '.env')

DOMAIN_TO_EXPORT = ARGV[0]
MAIN_NS = ENV["MAIN_NS"]
SOA_EMAIL_AS_FQDN = ENV["SOA_EMAIL_AS_FQDN"]
NS_RECORDS = ENV["NS_RECORDS"].split(" ")
DEFAULT_TTL = ENV["DEFAULT_TTL"]

DNSimple::Client.username = ENV["USERNAME"]
DNSimple::Client.password = ENV["PASSWORD"]

domain = DNSimple::Domain.find(DOMAIN_TO_EXPORT)
records = DNSimple::Record.all(domain)

header = <<-EOFS
	@    #{DEFAULT_TTL}   IN      SOA     #{MAIN_NS}. #{SOA_EMAIL_AS_FQDN}. (
	                        #{Time.now.strftime("%Y%m%d%H")}      ; serial YYYYMMDDHH
	                        #{DEFAULT_TTL}            ; refresh, seconds
	                        #{DEFAULT_TTL}            ; retry, seconds
	                        #{DEFAULT_TTL}000         ; expire, seconds
	                        86400 )         ; minimum, seconds
EOFS

puts header
puts

NS_RECORDS.each do |ns_hostname|
  puts "#{DOMAIN_TO_EXPORT}. #{DEFAULT_TTL} IN NS #{ns_hostname}."
end

records.each do |record|
  name = 
    if (record.name.nil? || record.name.empty?)
      "#{DOMAIN_TO_EXPORT}."
    else
      record.name
    end

  prio = record.prio.to_s unless record.prio.to_s.empty?

  txt_or_content = 
    if record.record_type == "TXT"
      %Q["#{record.content}"]
    else
      record.content
    end

  puts "#{name} #{record.ttl.to_s} IN #{record.record_type} #{prio} #{txt_or_content}"
end

  
