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
    my $r = analyze_voikko($self, $word);
    return @$r;
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
