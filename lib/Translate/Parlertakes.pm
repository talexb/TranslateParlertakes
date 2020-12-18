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

#  Looking at a keyboard, these are all of the neighboring letters.

my %nearby_letters = (
    q => [ qw/a s w/ ],
    w => [ qw/q a s d e/ ],
    e => [ qw/w s d f r/ ],
    r => [ qw/e d f g t/ ],
    t => [ qw/r f g h y/ ],
    y => [ qw/t g h j u/ ],
    u => [ qw/y h j k i/ ],
    i => [ qw/u j k l o/ ],
    o => [ qw/i k l p/ ],
    p => [ qw/o l/ ],

    a => [ qw/q w s x z/ ],
    s => [ qw/q w e a d z x c/ ],
    d => [ qw/w e r s f x c v/ ],
    f => [ qw/e r t d g c v b/ ],
    g => [ qw/r t y f h v b n/ ],
    h => [ qw/t y u g j b n m/ ],
    j => [ qw/y u i h k n m/ ],
    k => [ qw/u i o j l m/ ],
    l => [ qw/i o p k/ ],

    z => [ qw/a s x/ ],
    x => [ qw/z a s d c/ ],
    c => [ qw/x s d f v/ ],
    v => [ qw/c d f g b/ ],
    b => [ qw/v f g h n/ ],
    n => [ qw/b g h j m/ ],
    m => [ qw/n h j k/ ],
)

#  Fascinating .. we can use egrep to find some good matches for mwssafe as
#  follows:
#
#    $ egrep '^[mnhjk][wqasde][sqweadzxc][qweasdzxc][qwaszx][ertdfgcvb][wersdf]$' \
#    > /usr/share/dict/words
#    massage
#    message
#
#  The second choice is the correct one, but we won't know which. If we look at
#  'tue', we end of with many choices:
#
#    $ egrep '^[rtyfgh][yuihjk][wersdf]$' /usr/share/dict/words
#    fie
#    fir
#    fur
#    hid
#    hie
#    his
#    hue
#    rid
#    rue
#    rye
#    the
#    tie
#
#  This leaves us with an interesting further refinement .. picking the word
#  with the fewest differences from the original. Using that logic, hue, rue,
#  the and tie all differ by just one letter. We might be able to go with 'the'
#  based on word frequency ..
#
#  So our decode of the original message might end up looking like this:
#
#    MY (MESSAGE|MASSAGE) TO (HUE|RUE|THE|TIE) BITCH ON TWITTER ..
#
#  This isn't ideal, but it quickly shows what possibilities there are.


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
