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

# Path to administrator directory
my $admin_path;
# File handler
my $htaccess;
# Auth present flag
my $auth_present;

# Path to .htpasswd
my $htpasswd_path;

# Authentiation directives
my $auth = "AuthType Basic\nAuthName \"Administration zone\"\nAuthUserFile \"$htpasswd_path/.htpasswd\"\nRequire valid-user\n";

# Set admin dir path (relative)
$admin_path = "administrator";

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
	# Get array of VirtualHost on this ip and process each
	@vhosts = $apache_conf->cmd_context(VirtualHost => $vhip);
	foreach $vhost_context (@vhosts) {
		# Get ServerName, ServerAlias and DocumentRoot
		$server_name   = $vhost_context->cmd_config('ServerName');
		@server_alias  = $vhost_context->cmd_config('ServerAlias');
		$document_root = $vhost_context->cmd_config('DocumentRoot');
		
		# Search admin dir
		if (-d "$document_root/$admin_path") {
			# Search .htaccess
			if (-f "$document_root/$admin_path/.htaccess") {
				open($htaccess, "+<", "$document_root/$admin_path/.htaccess" ) or next;
				$auth_present = 0;
				# Search .htaccess for Auth
				while (<$htaccess>) {
					if ($_ =~ /AuthType/i) {
						$auth_present = 1;
						last;
					}
				}
				if (!$auth_present) {
					print "I want insert Auth in $document_root/$admin_path/.htaccess\n";
				}
				else {
					print "There is Auth: $document_root/$admin_path/.htaccess\n";
				}
			}
		}

	}
}

