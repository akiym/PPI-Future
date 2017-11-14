package PPI::Future::Token::QuoteLike;

=pod

=head1 NAME

PPI::Future::Token::QuoteLike - Quote-like operator abstract base class

=head1 INHERITANCE

  PPI::Future::Token::QuoteLike
  isa PPI::Future::Token
      isa PPI::Future::Element

=head1 DESCRIPTION

The C<PPI::Future::Token::QuoteLike> class is never instantiated, and simply
provides a common abstract base class for the five quote-like operator
classes. In PPI::Future, a "quote-like" is the set of quote-like things that
exclude the string quotes and regular expressions.

The subclasses of C<PPI::Future::Token::QuoteLike> are:

=over 2

=item qw{} - L<PPI::Future::Token::QuoteLike::Words>

=item `` - L<PPI::Future::Token::QuoteLike::Backtick>

=item qx{} - L<PPI::Future::Token::QuoteLike::Command>

=item qr// - L<PPI::Future::Token::QuoteLike::Regexp>

=item <FOO> - L<PPI::Future::Token::QuoteLike::Readline>

=back

The names are hopefully obvious enough not to have to explain what
each class is. See their pages for more details.

You may note that the backtick and command quote-like are treated
separately, even though they do the same thing. This is intentional,
as the inherit from and are processed by two different parts of the
PPI::Future's quote engine.

=cut

use strict;
use PPI::Future::Token ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Token";

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
