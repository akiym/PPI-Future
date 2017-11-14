package PPI::Future::Token::Regexp::Transliterate;

=pod

=head1 NAME

PPI::Future::Token::Regexp::Transliterate - A transliteration regular expression token

=head1 INHERITANCE

  PPI::Future::Token::Regexp::Transliterate
  isa PPI::Future::Token::Regexp
      isa PPI::Future::Token
          isa PPI::Future::Element

=head1 SYNOPSIS

  $text =~ tr/abc/xyz/;

=head1 DESCRIPTION

A C<PPI::Future::Token::Regexp::Transliterate> object represents a single
transliteration regular expression.

I'm afraid you'll have to excuse the ridiculously long class name, but
when push came to shove I ended up going for pedantically correct
names for things (practically cut and paste from the various docs).

=head1 METHODS

There are no methods available for C<PPI::Future::Token::Regexp::Transliterate>
beyond those provided by the parent L<PPI::Future::Token::Regexp>, L<PPI::Future::Token>
and L<PPI::Future::Element> classes.

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
