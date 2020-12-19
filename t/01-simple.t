#!/usr/bin/perl

use 5.006;
use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;

use lib "$Bin/../lib";

use Translate::Parlertakes;

{
    my $tp = Translate::Parlertakes->new;
    ok ( defined $tp, 'Created TP object' );

    my $sentence = 'you are correct';
    my $result = $tp->decode ( $sentence );

    ok ( defined $result, 'Got a result from encode for trivial sentence' );

    my @expected_words = split (/\s/, $sentence );
    foreach my $num ( 0 .. $#expected_words ) {

        is( $expected_words[$num], $result->[$num]->{orig},
            'Original matches' );
        ok(
            exists $result->[$num]->{result}->{exact},
            "Exact match for $expected_words[$num]"
        );
    }

    done_testing;
}
