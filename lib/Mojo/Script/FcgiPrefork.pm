# Copyright (C) 2008, Sebastian Riedel.

package Mojo::Script::FcgiPrefork;

use strict;
use warnings;

use base 'Mojo::Script';

use Mojo::Server::FCGI::Prefork;

__PACKAGE__->attr('description', chained => 1, default => <<'EOF');
* Start the fcgi_prefork script. *
Takes a path as option, by default :3000 will be used.
    fcgi_prefork
    fcgi_prefork :8080
    fcgi_prefork /some/unix.socket
EOF

# Oh boy! Sleep! That's when I'm a Viking!
sub run {
    my ($self, $path) = @_;
    my $fcgi = Mojo::Server::FCGI::Prefork->new;
    $fcgi->path($path) if $path;
    $fcgi->run;
    return $self;
}

1;
__END__

=head1 NAME

Mojo::Script::FcgiPrefork - FCGI Prefork Script

=head1 SYNOPSIS

    use Mojo::Script::FcgiPrefork;

    my $fcgi = Mojo::Script::FcgiPrefork->new;
    $fcgi->run(@ARGV);

=head1 DESCRIPTION

L<Mojo::Script::FcgiPrefork> is a script interface to
L<Mojo::Server::FCGI::Prefork>.

=head1 ATTRIBUTES

L<Mojo::Script::FcgiPrefork> inherits all attributes from L<Mojo::Script>
and implements the following new ones.

=head2 C<description>

    my $description = $fcgi->description;
    $fcgi           = $fcgi->description('Foo!');

=head1 METHODS

L<Mojo::Script::FcgiPrefork> inherits all methods from L<Mojo::Script> and
implements the following new ones.

=head2 C<run>

    $fcgi = $fcgi->run(@ARGV);

=cut