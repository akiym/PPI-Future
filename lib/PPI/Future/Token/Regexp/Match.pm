package PPI::Future::Token::Regexp::Match;

=pod

=head1 NAME

PPI::Future::Token::Regexp::Match - A standard pattern match regex

=head1 INHERITANCE

  PPI::Future::Token::Regexp::Match
  isa PPI::Future::Token::Regexp
      isa PPI::Future::Token
          isa PPI::Future::Element

=head1 SYNOPSIS

  $text =~ m/match regexp/;
  $text =~ /match regexp/;

=head1 DESCRIPTION

A C<PPI::Future::Token::Regexp::Match> object represents a single match regular
expression. Just to be doubly clear, here are things that are and
B<aren't> considered a match regexp.

  # Is a match regexp
  /This is a match regexp/;
  m/Old McDonald had a farm/eieio;
  
  # These are NOT match regexp
  qr/This is a regexp quote-like operator/;
  s/This is a/replace regexp/;

=head1 METHODS

There are no methods available for C<PPI::Future::Token::Regexp::Match> beyond
those provided by the parent L<PPI::Future::Token::Regexp>, L<PPI::Future::Token> and
L<PPI::Future::Element> classes.

=cut

use strict;
use PPI::Future::Token::Regexp             ();
use PPI::Future::Token::_QuoteEngine::Full ();

our $VERSION = '1.236';

our @ISA = qw{
	PPI::Future::Token::_QuoteEngine::Full
	PPI::Future::Token::Regexp
};

1;

=pod

=head1 SUPPORT

See the L<support section|PPI::Future/SUPPORT> in the main module.

=head1 AUTHOR

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2001 - 2011 Adam Kennedy.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
