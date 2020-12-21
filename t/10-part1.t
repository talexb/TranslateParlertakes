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

    #  A larger part of the first message .. this test is for 'OREIVATE' which
    #  is likely supposed to be PRIVATE, so this will test the logic that does
    #  a search by adding a letter.

    my $sentence = lc 'I NEVER ONCE GABE YOU PREMISSIONS AND I DEMAND THAT '
      .'TOU STOP MY ACCOUNT IS OREIVATE FOR A RWASOB BITCH';

    my $result = $tp->decode ( $sentence );

    ok ( defined $result, 'Got a result from encode for first fragment' );

    my @decoded;

    my @expected_words = split( /\s/, $sentence );

  WORD:
    foreach my $num ( 0 .. $#expected_words ) {

        if ( exists $result->[$num]->{result}->{exact} ) {

            ok( 1, "Exact match for '$expected_words[$num]'" );
            push( @decoded, $result->[$num]->{result}->{0}->[0] );

        } else {

            foreach my $p ( 0 .. length( $expected_words[$num] ) ) {

                if ( defined( $result->[$num]->{result}->{$p} ) ) {

                    my $count = scalar @{ $result->[$num]->{result}->{$p} };
                    ok( 1,
                            "Got $count off by "
                          . ( $p + 1 )
                          . " matches for '$expected_words[$num]'" );

                    if ( @{ $result->[$num]->{result}->{$p} } == 1 ) {

                        push( @decoded, @{ $result->[$num]->{result}->{$p} } );

                    } else {

                        push(
                            @decoded,
                            join(
                                '', '(',
                                join( '|',
                                    @{ $result->[$num]->{result}->{$p} } ),
                                ')'
                            )
                        );
                    }
                    next WORD;
                }
            }
            fail("Unable to get match for '$expected_words[$num]'");
        }
    }

    diag ( "Decoded sentence is '" . join ( ' ', @decoded ) . "'" );

    done_testing;
}
