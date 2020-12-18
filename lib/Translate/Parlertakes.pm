package Translate::Parlertakes;

use 5.006;
use strict;
use warnings;

=head1 NAME

Translate::Parlertakes - Translate into and out of @parlertakes lingo

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Translate::Parlertakes;

    my $original_mangled = 'MY MWSSAFE TO TUE BITCH ON TWITTER';
    my $translation = Translate::Parlertakes->decode ( $original_mangled );

    print "$original_mangled ->\n$translation\n";

    #  Outputs
    #  MY MWSSAFE TO TUE BITCH ON TWITTER ->
    #  MY MESSAGE TO THE BITCH ON TWITTER

    #  And then, to mangle that,

    my $new_mangled = Translate::Parlertakes->encode ( $translation );

    print "$translation ->\n$new_mangled\n";

    #  Outputs
    #  MY MESSAGE TO THE BITCH ON TWITTER ->
    #  MT MESSAFE TO YHE BITCH IN TWITTER
    #  .. or something with the same type of typing mistakes.
    ...
=cut

sub decode
{
}

sub encode
{
}

=head1 AUTHOR

T. Alex Beamish, C<< <talexb at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-translate-parlertakes at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Translate-Parlertakes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Translate::Parlertakes


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Translate-Parlertakes>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Translate-Parlertakes>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Translate-Parlertakes>

=item * Search CPAN

L<https://metacpan.org/release/Translate-Parlertakes>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2020 by T. Alex Beamish.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of Translate::Parlertakes
