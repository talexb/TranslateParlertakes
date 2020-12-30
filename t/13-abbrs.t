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

    my $sentence = 'the nafta agreement';
    my $result = $tp->decode ( $sentence );

    ok ( defined $result, 'Got a result from encode for first fragment' );

    #  Don't read the abbreviations file .. just cook up something to watch for
    #  the special case, and fix up the expected words array.

    my %abbrs = ( nafta => undef );
    my @expected_words = map { exists( $abbrs{$_} ) ? uc($_) : $_ }
      split( /\s/, $sentence );

    foreach my $num ( 0 .. $#expected_words ) {

        if ( exists $result->[$num]->{result}->{exact} ) {

            ok( 1, "There's an exact match for '$expected_words[$num]'" );
            is( $result->[$num]->{result}->{0}->[0],
                $expected_words[$num], 'Exact match' );

        } else {

            fail ( "Failed to see '$expected_words[$num]'" );
        }
    }

    done_testing;
}
