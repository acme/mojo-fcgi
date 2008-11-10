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

plan skip_all => 'set TEST_LIGHTTPD to enable this test (developer only!)'
  unless $ENV{TEST_LIGHTTPD};
plan tests => 9;

# You know, my kids think you're the greatest.
# And thanks to your gloomy music,
# they've finally stopped dreaming of a future I can't possibly provide.

use_ok('Mojo::Server::FCGI::Prefork');

# FastCGI prefork daemon
my $fcgi = Test::Mojo::Server->new;
my $executable = $fcgi->home->executable;
my $fport = $fcgi->generate_port_ok;
$fcgi->command("$executable fcgi_prefork :$fport");
$fcgi->start_server_untested_ok;

# Wait
sleep 2;

# Setup
my $server = Test::Mojo::Server->new;
my $port   = $server->generate_port_ok;
my $script = $server->home->executable;
my $dir    = File::Temp::tempdir();
my $config = File::Spec->catfile($dir, 'fcgi.config');
my $mt     = Mojo::Template->new;

$mt->render_to_file(<<'EOF', $config, $dir, $port, $fport);
% my ($dir, $port, $fport) = @_;
server.modules = (
    "mod_access",
    "mod_fastcgi",
    "mod_rewrite",
    "mod_accesslog"
)

server.document-root = "<%= $dir %>"
server.errorlog    = "<%= $dir %>/error.log"
accesslog.filename = "<%= $dir %>/access.log"

server.bind = "127.0.0.1"
server.port = <%= $port %>

fastcgi.server = (
    "/test" => (
        "FastCgiTest" => (
            "host"            => "127.0.0.1",
            "port"            => <%= $fport %>,
            "check-local"     => "disable"
        )
    )
)
EOF
# Start
$server->command("lighttpd -D -f $config");
$server->start_server_ok;

# Request
my $tx = Mojo::Transaction->new_get("http://127.0.0.1:$port/test/");
my $client = Mojo::Client->new;
$client->process_all($tx);
is($tx->res->code, 200);
like($tx->res->body, qr/Mojo is working/);

# Stop
$fcgi->stop_server_ok;
$server->stop_server_ok;