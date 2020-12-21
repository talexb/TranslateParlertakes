#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

#  2020-1220: Command line interface into Translate::Parlertakes::decode. Takes
#  a mangled sentence as input and outputs a plausible translation.

use Translate::Parlertakes;

{
    my $tp = Translate::Parlertakes->new;
    defined $tp or die "Unable to initialize Translate::Parlertakes.";

    my @lines;
    while (<>) {

        chomp;
        push ( @lines, $_ );
    }

    my $result = $tp->decode ( join ( ' ', @lines ) );
    
    #  Show the original sentence ..

    my @words = split ( /\s+/, join ( ' ', @lines ) );

    print "Input sentence was:\n";
    do_wrapped_output ( \@words );

    #  Gather output and put the best spin on it ..

    my @words2;
    foreach my $r (@$result) {

        if ( $r->{orig} eq '' ) { next; }

        if ( exists $r->{result}->{exact} ) {

            push( @words2, $r->{result}->{0}->[0] );

        } else {

            foreach my $v ( 1 .. length( $r->{orig} ) ) {

                if ( exists $r->{result}->{$v} ) {

                    if ( @{ $r->{result}->{$v} } == 1 ) {

                        push( @words2, $r->{result}->{$v}->[0] );

                    } else {

                        push( @words2,
                            '(' . join( '|', @{ $r->{result}->{$v} } ) . ')' );
                    }
                }
            }
        }
    }

    print "Result is:\n";

    do_wrapped_output ( \@words2 );
}

sub do_wrapped_output
{
    my ( $words ) = @_;

    my $output_len = 0;
    my @out;

    foreach my $w ( @$words ) {

        if ( $output_len + length ( $w ) > 76 ) {

            print join ( ' ', @out ) . "\n";

            $output_len = 0;
            @out = ();
        }
        push ( @out, $w );
        $output_len += length ( $w ) + 1;
    }

    if ( $output_len ) {

        print join ( ' ', @out ) . "\n";
    }
}
