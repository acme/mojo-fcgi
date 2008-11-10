# Copyright (C) 2008, Sebastian Riedel.

package Mojo::Script::Fcgi;

use strict;
use warnings;

use base 'Mojo::Script';

use Mojo::Server::FCGI;

__PACKAGE__->attr('description', chained => 1, default => <<'EOF');
* Start the fcgi script. *
Takes no options.
    fcgi
EOF

# Oh boy! Sleep! That's when I'm a Viking!
sub run {
    Mojo::Server::FCGI->new->run;
    return shift;
}

1;
__END__

=head1 NAME

Mojo::Script::Fcgi - FCGI Script

=head1 SYNOPSIS

    use Mojo::Script::Fcgi;

    my $fcgi = Mojo::Script::Fcgi->new;
    $fcgi->run(@ARGV);

=head1 DESCRIPTION

L<Mojo::Script::Fcgi> is a script interface to L<Mojo::Server::FCGI>.

=head1 ATTRIBUTES

L<Mojo::Script::Fcgi> inherits all attributes from L<Mojo::Script> and
implements the following new ones.

=head2 C<description>

    my $description = $fcgi->description;
    $fcgi           = $fcgi->description('Foo!');

=head1 METHODS

L<Mojo::Script::Fcgi> inherits all methods from L<Mojo::Script> and
implements the following new ones.

=head2 C<run>

    $fcgi = $fcgi->run(@ARGV);

=cut