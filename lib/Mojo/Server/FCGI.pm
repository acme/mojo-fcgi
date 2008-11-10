# Copyright (C) 2008, Sebastian Riedel.

package Mojo::Server::FCGI;

use strict;
use warnings;

use base 'Mojo::Server';
use bytes;

use FCGI;

our $VERSION = '0.01';

# Wow! Homer must have got one of those robot cars!
# *Car crashes in background*
# Yeah, one of those AMERICAN robot cars.
sub process {
    my $self = shift;

    my $tx  = $self->build_tx_cb->($self);
    my $req = $tx->req;

    # Environment
    $req->parse(\%ENV);

    # Request body
    $req->state('body');
    while (!$req->is_state(qw/done error/)) {
        last unless (my $read = STDIN->sysread(my $buffer, 4096, 0)) >= 0;
        $req->parse($buffer);
    }

    # Handle
    $self->handler_cb->($self, $tx);

    my $res = $tx->res;

    # Response start line
    my $offset = 0;
    while (1) {
        my $chunk = $res->get_start_line_chunk($offset);

        # No start line yet, try again
        unless (defined $chunk) {
            sleep 1;
            next;
        }

        # End of start line
        last unless length $chunk;

        # Start line
        STDOUT->syswrite($chunk);
        $offset += length $chunk;
    }

    # Response headers
    my $code = $res->code;
    my $message = $res->message || $res->default_message;
    $offset = 0;
    while (1) {
        my $chunk = $res->get_header_chunk($offset);

        # No headers yet, try again
        unless (defined $chunk) {
            sleep 1;
            next;
        }

        # End of headers
        last unless length $chunk;

        # Headers
        STDOUT->syswrite($chunk);
        $offset += length $chunk;
    }

    # Response body
    $offset = 0;
    while (1) {
        my $chunk = $res->get_body_chunk($offset);

        # No content yet, try again
        unless (defined $chunk) {
            sleep 1;
            next;
        }

        # End of content
        last unless length $chunk;

        # Content
        STDOUT->syswrite($chunk);
        $offset += length $chunk;
    }

    return $res->code;
}

sub run {
    my $self = shift;
    my $request = FCGI::Request();
    while($request->Accept() >= 0) {
        $self->process;
    }
}

1;
__END__

=head1 NAME

Mojo::Server::FCGI - Speedy FastCGI Server

=head1 SYNOPSIS

    use Mojo::Server::FCGI;
    my $fcgi = Mojo::Server::FCGI->new;
    $fcgi->run;

=head1 DESCRIPTION

L<Mojo::Server::FCGI> is a very speedy FastCGI implementation using L<FCGI>
and the preferred deployment option for production servers under heavy load.

=head1 ATTRIBUTES

L<Mojo::Server::FCGI> inherits all attributes from L<Mojo::Server>.

=head1 METHODS

L<Mojo::Server::FCGI> inherits all methods from L<Mojo::Server> and
implements the following new ones.

=head2 C<process>

    $fcgi->process;

=head2 C<run>

    $fcgi->run;

=cut