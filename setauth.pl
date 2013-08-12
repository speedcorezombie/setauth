#!/usr/bin/perl 

use strict;
use warnings;
use lib '/root/scripts/apache-to-ngx/modules/';
use Apache::ConfigFile;

# Apache configuration file
my $httpd_conf;

# Parsed configuration
my $apache_conf;

# VirtualHost IPs array
my @vhosts_ip;

# VirtualHost array
my @vhosts;

# VirtualHost context
my $vhost_context;

# Virtual host's variables
# ServerName
my $server_name;
# ServerAlias array
my @server_alias;
# DocumentRoot
my $document_root;

# Set config file path
$httpd_conf = "/usr/local/apache/conf/httpd.conf";                                                                                                          
                                                                                                                                                            
# Parse configuration                                                                                                                                       
$apache_conf = Apache::ConfigFile->read(file => $httpd_conf,
										ignore_case  => 1,
										expand_vars  => 1,
										fix_booleans => 1
				);

# Get array of VirtualHost ips and process each
@vhosts_ip = $apache_conf->cmd_context('VirtualHost');
foreach my $vhip (@vhosts_ip) {
	# Get array of VirtualHost on this ip
	@vhosts = $apache_conf->cmd_context(VirtualHost => $vhip);
	foreach $vhost_context (@vhosts) {
		$server_name   = $vhost_context->cmd_config('ServerName');
		@server_alias  = $vhost_context->cmd_config('ServerAlias');
		$document_root = $vhost_context->cmd_config('DocumentRoot');
	}
}

