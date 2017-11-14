package PPI::Future::Token::Quote::Interpolate;

=pod

=head1 NAME

PPI::Future::Token::Quote::Interpolate - The interpolation quote-like operator

=head1 INHERITANCE

  PPI::Future::Token::Quote::Interpolate
  isa PPI::Future::Token::Quote
      isa PPI::Future::Token
          isa PPI::Future::Element

=head1 DESCRIPTION

A C<PPI::Future::Token::Quote::Interpolate> object represents a single
interpolation quote-like operator, such as C<qq{$foo bar $baz}>.

=head1 METHODS

There are no methods available for C<PPI::Future::Token::Quote::Interpolate>
beyond those provided by the parent L<PPI::Future::Token::Quote>, L<PPI::Future::Token> and
L<PPI::Future::Element> classes.

=cut

use strict;
use PPI::Future::Token::Quote ();
use PPI::Future::Token::_QuoteEngine::Full ();

our $VERSION = '1.236';

our @ISA = qw{
	PPI::Future::Token::_QuoteEngine::Full
	PPI::Future::Token::Quote
};





#####################################################################
# PPI::Future::Token::Quote Methods

sub string {
	my $self     = shift;
	my @sections = $self->_sections;
	my $str      = $sections[0];
	substr( $self->{content}, $str->{position}, $str->{size} );	
}

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
