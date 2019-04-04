package Lingua::Voikko;

use 5.022001;
use strict;
use warnings;
use utf8;

require Exporter;

our @ISA = qw(Exporter);

use Carp;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Lingua::Voikko ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Lingua::Voikko', $VERSION);

use constant SIJAMUOTO_WEIGHTS => {
    nimento => 0,
    keinonto => 2,
    osanto => 2,
    sisatulento => 0,
};

use constant MOOD_WEIGHTS => {
    'A-infinitive' => 0,
    'MA-infinitive' => 0,
    indicative => 0,
    imperative => 1,
};

use constant TENSE_WEIGHTS => {
    'past_imperfective' => 1,
    'present_simple' => 0,
};

use constant CLASS_WEIGHTS => {
    huudahdussana => 2,
    nimisana => 2,
    teonsana => 2,
    laatusana => 2,
    paikannimi => 1,
    etunimi => 1,
    nimi => 1,
    sukunimi => 0, # words such as Koivisto and Soini
    seikkasana => 2,
};

use constant BASEFORM_WEIGHTS => {
    puola => 1,
    varjopuola => 1,
    pidin => 1,
    suoda => 1,
    kirjo => 1,
    luokki => 2,
    voi => 1,
    vaalia => 1,
    kulti => 2,
    murhakulti => 2,
    
    kaveriporukassa => 1000,
    porukassa => 1000,
    hertsikassa => 1000,
    työporukassa => 1000,
    kurikassa => 1000,
    sähkötupakassa => 1000,
    koirankakassa => 1000,
    ydinporukassa => 1000,
    majakassa => 1000,
    hutikassa => 1000,
    torakassa => 1000,
    karsikassa => 1000,
    aulankassa => 1000,
    hetekassa => 1000,
    rakennusurakassa => 1000,
    urakassa => 1000,
    potaattiurakassa => 1000,
    toonikassa => 1000,
    sopukassa => 1000,
    namikassa => 1000,
    vilkkumajakassa => 1000,
    majakassa => 1000,
    mansikassa => 1000,
    tupakassa => 1000,
    
    gedit => 1000,
    pine => 1000,
    mutt => 1000,
    lyx => 1000,
    latex => 1000,
    aspell => 1000,
    yum => 1000,
    tex => 1000
};

use constant PARTICIPLE_WEIGHTS => {
    agent => 1,
};

use constant COMPARISON_WEIGHTS => {
    positive => 0, # ?
    superlative => 1,
};

use constant PERSON_WEIGHTS => {
    1 => 1,
    2 => 1,
    3 => 0,
    4 => 0,
};

# Preloaded methods go here.

sub new($@)
{
    my $class = shift;

    my ($lang, $path) = @_;    

    my ($self, $error, $errtxt) = new_voikko($lang, $path);

    croak $errtxt if defined $errtxt;
    
    $self;
}

sub spell($)
{
    my ($self, $word) = @_;
    spell_voikko($self, $word);
}

sub suggest($)
{
    my ($self, $word) = @_;
    my $r = suggest_voikko($self, $word);
    return @$r;
}

sub analyze($)
{
    my ($self, $word) = @_;
    my $rr = analyze_voikko($self, $word);
    for my $r (@$rr) {
	my $c = 0;
	if (defined $r->{SIJAMUOTO}) {
	    my $w = SIJAMUOTO_WEIGHTS->{$r->{SIJAMUOTO}}; 
	    $c += defined $w ? $w : 1;
	}
	if (defined $r->{POSSESSIVE}) {
	    $c++;
	}
	if (defined $r->{MOOD}) {
	    my $w = MOOD_WEIGHTS->{$r->{MOOD}};
	    $c += defined $w ? $w : 1;
	}
	if (defined $r->{TENSE}) {
	    my $w = TENSE_WEIGHTS->{$r->{TENSE}};
	    $c += defined $w ? $w : 1;
	}
	if (defined $r->{CLASS}) {
	    my $class = $r->{CLASS};
	    if (($class eq 'paikannimi' || $class eq 'etunimi' || $class eq 'sukunimi' || $class eq 'nimi') && (ucfirst lc $word) ne $word) {
		# If the word does not start with a capital letter, it might not be a proper noun
		$c += 1;
	    }
	    my $w = CLASS_WEIGHTS->{$class};
	    $c += defined $w ? $w : 1;
	}
	if (defined $r->{COMPARISON}) {
	    my $w = COMPARISON_WEIGHTS->{$r->{COMPARISON}};
	    $c += defined $w ? $w : 1;
	}
	if (defined $r->{PARTICIPLE}) {
	    my $w = PARTICIPLE_WEIGHTS->{$r->{PARTICIPLE}};
	    $c += defined $w ? $w : 1;
	}
	if (defined $r->{PERSON}) {
	    my $w = PERSON_WEIGHTS->{$r->{PERSON}};
	    die "error: $r->{PERSON}" if !defined $w;
	    $c += $w;
	}
	if (defined $r->{NUMBER} && $r->{NUMBER} eq 'plural') {
	    $c += 1;
	}
	if (defined $r->{WORDBASES}) {
	    my $p = 0;
	    while ($r->{WORDBASES} =~ /\+[^\(]+\([^\)]+\)/g) {
		$p++;
	    }
	    # print STDERR "parts from $r->{WORDBASES}: $p\n";
	    $c += 3 * $p;
	}
	if (defined $r->{BASEFORM}) {
	    my $w = BASEFORM_WEIGHTS->{$r->{BASEFORM}};
	    $c += $w if $w;
	}
	$r->{COMPLEXITY} = $c;
    }
    return sort { $a->{COMPLEXITY} <=> $b->{COMPLEXITY} } @$rr;
}

sub hyphenate($)
{
    my ($self, $word) = @_;
    my ($r, $error, $error_text) = hyphenate_voikko($self, $word);
    croak "failed to hyphenate" if !defined $r;
    return $r;
}

sub tokenize($)
{
    my ($self, $string) = @_;
    
}



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Lingua::Voikko - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Lingua::Voikko;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Lingua::Voikko, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Mikael Rekola, E<lt>rekola@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Mikael Rekola

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.22.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
