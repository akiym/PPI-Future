package PPI::Future::Token::QuoteLike::Readline;

=pod

=head1 NAME

PPI::Future::Token::QuoteLike::Readline - The readline quote-like operator

=head1 INHERITANCE

  PPI::Future::Token::QuoteLike::Readline
  isa PPI::Future::Token::QuoteLike
      isa PPI::Future::Token
          isa PPI::Future::Element

=head1 DESCRIPTION

The C<readline> quote-like operator is used to read either a single
line from a file, or all the lines from a file, as follows.

  # Read in a single line
  $line = <FILE>;
  
  # From a scalar handle
  $line = <$filehandle>;
  
  # Read all the lines
  @lines = <FILE>;

=head1 METHODS

There are no methods available for C<PPI::Future::Token::QuoteLike::Readline>
beyond those provided by the parent L<PPI::Future::Token::QuoteLike>, L<PPI::Future::Token>
and L<PPI::Future::Element> classes.

=cut

use strict;
use PPI::Future::Token::QuoteLike          ();
use PPI::Future::Token::_QuoteEngine::Full ();

our $VERSION = '1.236';

our @ISA = qw{
	PPI::Future::Token::_QuoteEngine::Full
	PPI::Future::Token::QuoteLike
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
