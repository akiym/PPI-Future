package PPI::Future::Token::QuoteLike::Backtick;

=pod

=head1 NAME

PPI::Future::Token::QuoteLike::Backtick - A `backticks` command token

=head1 INHERITANCE

  PPI::Future::Token::QuoteLike::Backtick
  isa PPI::Future::Token::QuoteLike
      isa PPI::Future::Token
          isa PPI::Future::Element

=head1 DESCRIPTION

A C<PPI::Future::Token::QuoteLike::Backtick> object represents a command output
capturing quote.

=head1 METHODS

There are no methods available for C<PPI::Future::Token::QuoteLike::Backtick>
beyond those provided by the parent L<PPI::Future::Token::QuoteLike>, L<PPI::Future::Token>
and L<PPI::Future::Element> classes.

=cut

use strict;
use PPI::Future::Token::QuoteLike            ();
use PPI::Future::Token::_QuoteEngine::Simple ();

our $VERSION = '1.236';

our @ISA = qw{
	PPI::Future::Token::_QuoteEngine::Simple
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
