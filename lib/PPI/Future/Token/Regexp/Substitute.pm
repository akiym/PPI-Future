package PPI::Future::Token::Regexp::Substitute;

=pod

=head1 NAME

PPI::Future::Token::Regexp::Substitute - A match and replace regular expression token

=head1 INHERITANCE

  PPI::Future::Token::Regexp::Substitute
  isa PPI::Future::Token::Regexp
      isa PPI::Future::Token
          isa PPI::Future::Element

=head1 SYNOPSIS

  $text =~ s/find/$replace/;

=head1 DESCRIPTION

A C<PPI::Future::Token::Regexp::Substitute> object represents a single substitution
regular expression.

=head1 METHODS

There are no methods available for C<PPI::Future::Token::Regexp::Substitute>
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
