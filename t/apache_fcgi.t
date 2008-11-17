#!perl

# Copyright (C) 2008, Sebastian Riedel.

use strict;
use warnings;

use Test::More;

use File::Spec;
use File::Temp;
use Mojo::Client;
use Mojo::Template;
use Mojo::Transaction;
use Test::Mojo::Server;

plan skip_all => 'set TEST_APACHE to enable this test (developer only!)'
  unless $ENV{TEST_APACHE};
plan tests => 6;

# They think they're so high and mighty,
# just because they never got caught driving without pants.
use_ok('Mojo::Server::FCGI');

# Setup
my $server = Test::Mojo::Server->new;
my $port   = $server->generate_port_ok;
my $script = $server->home->executable;
my $dir    = File::Temp::tempdir();
my $config = File::Spec->catfile($dir, 'apache.conf');
my $mt     = Mojo::Template->new;

$mt->render_to_file(<<'EOF', $config, $dir, $port, $script);
% my ($dir, $port, $script) = @_;
% use File::Spec::Functions 'catfile'
ServerName 127.0.0.1
Listen <%= $port %>

LoadModule log_config_module libexec/apache2/mod_log_config.so

ErrorLog <%= catfile $dir, 'error.log' %>

LoadModule alias_module libexec/apache2/mod_alias.so
LoadModule fastcgi_module libexec/apache2/mod_fastcgi.so

PidFile <%= catfile $dir, 'httpd.pid' %>
LockFile <%= catfile $dir, 'accept.lock' %>

DocumentRoot  <%= $dir %>

FastCgiIpcDir <%= $dir %>
FastCgiServer <%= $script %> -processes 1
Alias / <%= $script %>/

EOF

# Start
$server->command("/usr/sbin/httpd -X -f $config");
$server->start_server_ok;

# Request
my $tx = Mojo::Transaction->new_get("http://127.0.0.1:$port/test/");
my $client = Mojo::Client->new;
$client->process_all($tx);
is($tx->res->code, 200);
like($tx->res->body, qr/Mojo is working/);

# Stop
$server->stop_server_ok;