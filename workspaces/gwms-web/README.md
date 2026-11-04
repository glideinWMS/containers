# Scripts and Configuration files for gwms-web

These files can be used in a container or in the actual proxy host (like gwms-web)

There is a configuration for the httpd reverse proxy (gwms-web.config)
and multiple alternative configurations for the Hairpin NAT / NAT Reflection (all other files)
using nft configuration, a script that adds/removes the firewall configuration,
a ncat service.
