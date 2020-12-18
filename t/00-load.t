#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Translate::Parlertakes' ) || print "Bail out!\n";
}

diag( "Testing Translate::Parlertakes $Translate::Parlertakes::VERSION, Perl $], $^X" );
