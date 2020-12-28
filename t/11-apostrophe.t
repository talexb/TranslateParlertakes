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

    my $sentence = 'i wasnt there';
    my $result = $tp->decode ( $sentence );

    $sentence =~ s/nt(\b)?/n't$1/;

    ok ( defined $result, 'Got a result from encode for first fragment' );

    my @decoded;

    my @expected_words = split ( /\s/, $sentence );

    foreach my $num ( 0 .. $#expected_words ) {

        if ( exists $result->[$num]->{result}->{exact} ) {

            ok( 1, "Exact match for '$expected_words[$num]'" );
            is( $result->[$num]->{result}->{0}->[0],
                $expected_words[$num], 'Got matching word' );

        } else {

            fail ( "Did not get match for $expected_words[ $num ]" );
        }
    }

    done_testing;
}

