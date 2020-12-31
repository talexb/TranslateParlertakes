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

    #  Part of the first message ..

    my $sentence = lc 'TO TUE BITCH';
    my $result = $tp->decode ( $sentence );

    ok ( defined $result, 'Got a result from encode for first fragment' );

    my @expected_words = split( /\s/, $sentence );
    foreach my $num ( 0 .. $#expected_words ) {

        is( $result->[$num]->{orig},
            $expected_words[$num], 'Original matches' );

        #  Because we're working with known data, we're expecting two exact
        #  matches, and one off by one match with four choices.

        if ( exists $result->[$num]->{result}->{exact} ) {

            ok( 1, "Exact match for '$expected_words[$num]'" );

        } else {

            ok( defined( $result->[$num]->{result}->{1} ),
                "Got an off by one match for '$expected_words[$num]'" );
        }
    }

    done_testing;
}
