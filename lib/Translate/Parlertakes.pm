package Translate::Parlertakes;

use 5.006;
use strict;
use warnings;

use FindBin qw/$Bin/;
use List::Util qw/uniq/;

our $ERROR;

=head1 NAME

Translate::Parlertakes - Translate into and out of @parlertakes lingo

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our @EXPORT = qw/new decode encode/;


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
);

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

#  Another refinement is to add logic to see if we can add a letter as
#  necessary. Another recent message had THER instead of THERE, and cycling
#  through the possibilities (adding a letter in all of the positions) we did
#  end up with the intended word THERE.

#  Perhaps the result could be something like an array of hashes that would
#  show matches with the right length (0 length difference), possibly matches
#  (still with the right length), and then possible matches with one less
#  and/or one more letter. The caller would have to figure out how to display
#  the results.
#
#  So the decode above could return something like this:
#
#  $result = [
#    { orig => 'MY',      exact => 1 },  #  found in dict
#    { orig => 'MWSSAFE', 0 => [ qw/MESSAGE MASSAGE/ ] },
#                              #  two possibilities
#    { orig => 'TO',      exact => 1 },
#    { orig => 'TUE',     0 => [ qw/HUE RUE THE TIE ] },
#                              #  four poss.
#
#  For the mangled word OREIVATE (PRIVATE), we'd show that there were no exact
#  matches, but we did find one at -1 (that is, by deleting a letter):
#
#  $result = [
#    ..
#    { orig => 'OREIVATE', 0 => [], -1 => [ qw/PRIVATE/ ] }
#    ..
#
#  This would be our way of saying, "We didn't find an exact match at all, but
#  we got a good match at -1."

#  Create an object. This does nothing except make sure we have egrep and that
#  we can find the dictionary file.

my $egrep_prog      = 'egrep';
my $dictionary_file = '/usr/share/dict/words';
my $names_file      = "$Bin/../lib/Translate/names";    #  May need to change.
my $abbrs_file      = "$Bin/../lib/Translate/abbreviations";

my ( %proper_names, %abbrs );

sub new
{
    my ( $class ) = shift;

    my @test_egrep = `$egrep_prog -v 2>&1`;
    if ( $test_egrep[0] !~ /Usage/ ) {

        $ERROR = "Unable to run egrep";
        return undef;
    }

    if ( !-e $dictionary_file ) {

        $ERROR = "Unable to find dictionary file $dictionary_file";
        return undef;
    }

    if ( !-e $names_file ) {

        $ERROR = "Unable to find names file $names_file";
        return undef;
    }

    if ( !-e $abbrs_file ) {

        $ERROR = "Unable to find abbreviations file $abbrs_file";
        return undef;
    }

    open ( my $fh, $names_file );
    %proper_names = map { chomp; $_ => undef } grep { length > 2 } <$fh>;
    close ( $fh );

    open ( $fh, $abbrs_file );
    %abbrs = map { chomp; $_ => undef } grep { length > 2 } <$fh>;
    close ( $fh );

    my $self = {};
    bless $self, $class;

    return $self;
}

sub decode
{
    my ( $self, $string ) = @_;

    #  Split the input sentence into lower case words.

    my @words = map { lc } split ( /\s+/, $string );

    #  Return an arrayref with the original word and the results. There could
    #  be a) an exact match (means the word was found in the dictionary), b) a
    #  same-length match, and c) matches that are +1 and -1 in length from the
    #  original.

    my @results =
      map { { orig => $_, result => $self->_decode_word($_) } } @words;
    return \@results;
}

sub _decode_word
{
    my ( $self, $word ) = @_;

    #  See if the word's in the dictionary. if so, we're done.

    #  We need to find an exact match, so there's an anchor at the front and
    #  back with ^ and $. Since we're inside back-ticks, the '$' at the end
    #  needs to be escaped. And since egrep sends output to stdout, we don't
    #  need to do anything with piping. Finally, egrep sends a list with
    #  newlines at the end, so we have to chomp each line before checking for a
    #  match.

    my @result;
    {
        #  It could be that the apostrophe is missing from a word, as in the
        #  case of WASNT, so I'm adding a possible apostrophe. If the word was
        #  BENT, the extra character will be skipped and we should be OK.

        my $word2 = $word;
        if ( $word2 =~ /nt$/i ) {

            $word2 =~ s/nt$/n'?t/i;
        }

        #  2020-1229: Add the names file first so that if we get a hit there,
        #  but not in the dictionary file, we are still OK.

        #  2020-1230: Add the abbreviations file.

        @result = uniq map { chomp; $_ }
          `$egrep_prog -h "^$word2\$" $names_file $abbrs_file $dictionary_file`;
        if ( @result == 1 && $result[0] =~ $word2 ) {

            $result[0] = _maybe_adjust_case ( $result[0] );
            return ( { exact => 1, 0 => \@result } );
        }
    }

    #  OK, it's not in the dictionary. We're going to assume that one or more
    #  of the letters were mis-typed, so we'll replace each letter with all of
    #  the letters around the sample letter, and see if we get any matches.

    my @c = split ( //, $word );
    @result = _try_this ( @c );

    #  We might have an exact match -- like when letters have been transposed.
    #  That would be cool. (So, premissions -> permissions.)

    if ( @result == 1 && $result[0] eq $word ) {

        return ( { 0 => \@result } );
    }

    #  We now have a list of possible matches. We now need to score those
    #  matches against the original word to find the ones that match the best
    #  (and there may be more than one).

    my @score;
    _score_this ( \@c, \@result, $#c+1, \@score );

    #  2020-1230: At this point, we might have a single match that's only off
    #  by one (like SOROD -> SOROS) .. let's try that.

    if ( defined $score[1] && @{ $score[1] } == 1 ) {

        $score[1]->[0] = _maybe_adjust_case ( $score[1]->[0] );
        return ( { 1 => [ $score[1]->[0] ] } );
    }

    #  Next, we're going to try deleting one of the letters to see if we can a
    #  better match. This is going to be a little trickier, because we'll have
    #  to delete a letter, and then score the resulting word all in one loop.

    foreach my $d ( 0..$#c ) {

        my @w;
        if ( $d > 0 ) {

            push( @w, @c[ 0 .. $d - 1 ] );
            push( @w, @c[ $d + 1 .. $#c ] );

        } else {

            push( @w, @c[ 1 .. $#c ] );
        }

        @result = _try_this ( @w );
        
        #  Now we score this guess (using code copied from above.  Note that we
        #  are starting with the original length ($#c+1) because we're scoring
        #  this higher by one because we've deleted one of the original
        #  characters.

        _score_this ( \@w, \@result, $#c+1, \@score );
    }

    #  We now have a list of lists with words in the slots relative to how few
    #  they didn't match with the original -- we already know there were no
    #  exact matches, so the best outcome is that we have some matches in
    #  offset 1. We'll take the best outcome (the lowest number).

    for my $o ( 1..$#c+1 ) {

        if ( defined $score[ $o ] ) {

            return ( { $o => $score[ $o ] } );
        }
    }

    #  OK .. no matches for words of the same length. Now we have to try adding
    #  a letter .. and deleting a letter.

    return undef;
}

sub _try_this
{
    my ( @c ) = @_;

    my @poss = map { join ( '', $_, @{ $nearby_letters{ $_ } } ) } @c;
    my $regex = join ( '', map { "[$_]" } @poss );

    my @result =
      map { chomp; $_ } `$egrep_prog -h "^$regex\$" $names_file $abbrs_file $dictionary_file`;

    return ( @result );
}

sub _score_this
{
    #  Passing in the word we're starting with, the array of results from
    #  egrep, the length of the match we're looking for, and the score arrayref
    #  that gets used to two times that this routine is called.

    my ( $word, $result, $len, $score ) = @_;

    foreach my $res ( @$result ) {

        my @r = split ( //, $res );
        my $match = $len;

        #  Every time a character matches between the word we're starting with
        #  and the egrep result, we reduce the match count. Lower is better.

        foreach my $o ( 0..$#$word ) {

            if ( $word->[ $o ] eq $r[ $o ] ) { $match--; }
        }
        push ( @{ $score->[ $match ] }, $res );
    }

    #  Nothing's returned because the score is passing back the results.
}

sub _maybe_adjust_case
{
    my ($word) = @_;

    #  2020-1229: If we got an exact match, and if this is a proper name, let's
    #  capitalize it.

    if ( exists $proper_names{$word} ) {

        $word = ucfirst($word);
    }

    #  2020-1230: Same thing for abbreviations, except we're going to
    #  capitalize the entire word.

    if ( exists $abbrs{$word} ) {

        $word = uc($word);
    }

    return ($word);
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
