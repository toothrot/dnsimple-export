# DNSimple exporter

I use DNSimple and wanted to enable some of my domains for CloudFlare. This involves replicating your DNS zone on CloudFlare's servers.

Which, y'know, is fine - CloudFlare accept BIND-style zone files.  So I'll just go to DNSimple and press Expor...oh.

This is a **very very hacky** script that reads from DNSimple using the dnsimple-ruby RubyGem, then writes out a BIND-format zone file good enough for export.

## Known bugs

Zone serial number is unique to the hour.  This shouldn't present a problem as far as I know for a CloudFlare import, but for any other purposes you might need to edit it. Format is YYYYMMDDHH.

## Setting up

I'll assume you have Ruby and RubyGems already.

Install the dnsimple-ruby gem -

`gem install dnsimple-ruby`

You might need to do this as the superuser if you're not using RVM -

`sudo gem install dnsimple-ruby`

Copy auth.config.sample to auth.config and edit it with your DNSimple credentials.

Edit `.env` or `~/.dnsimple-ruby` and change the following -

### MAIN_NS

This is the nameserver specified in the SOA header.  Use one of the nameservers CloudFlare ask you to use for your domain.  Doesn't matter which.

### SOA_EMAIL_AS_FQDN

This is your email address in FQDN format. For example, dave@dave.io becomes dave.dave.io

### NS_RECORDS

These are the nameservers for your domain - DNSimple doesn't give any access to them as they're currently set.  Ruby array format, look it up if you can't work it out.

### DEFAULT_TTL

Time to live for various records, including SOA. Don't fiddle with this if you don't know what it means.

### USERNAME and PASSWORD

## Running the export

`ruby dnsimple-export.rb yourdomain.tld`

Replace `yourdomain.tld` with the domain to export.  Results go to STDOUT, so you can pipe it or redirect to a file if you want.
