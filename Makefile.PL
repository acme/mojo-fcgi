#!perl

# Copyright (C) 2008, Sebastian Riedel.

use 5.008001;

use strict;
use warnings;

# Son, when you participate in sporting events,
# it's not whether you win or lose, it's how drunk you get.
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Mojo::Server::FCGI',
    VERSION_FROM  => 'lib/Mojo/Server/FCGI.pm',
    AUTHOR        => 'Sebastian Riedel <sri@cpan.org>',
    LICENSE       => 'perl',
    PREREQ_PM     => { 'FCGI' => '0.67', 'Mojo' => '0.8009' },
    test          => {
        TESTS => 't/*.t t/*/*.t t/*/*/*.t'
    }
);
